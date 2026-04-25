//  CoreServicesTests.swift
//  Created by Sebastian Burrieza on 13/04/2026.

import XCTest
@testable import CoreServices

// MARK: - MockURLProtocol

/// Intercepts all URLSession requests in tests — no real network calls ever leave the process.
///
/// Usage:
/// ```swift
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [MockURLProtocol.self]
/// let session = URLSession(configuration: config)
/// ```
final class MockURLProtocol: URLProtocol {

    /// Set this before each test to control what the mock returns.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    // swiftlint:disable:next static_over_final_class
    override class func canInit(with request: URLRequest) -> Bool { true }
    // swiftlint:disable:next static_over_final_class
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - URLSessionNetworkServiceTests

final class URLSessionNetworkServiceTests: XCTestCase {

    var sut: URLSessionNetworkService!

    override func setUp() {
        super.setUp()
        sut = makeSUT()
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeSUT(
        tokenProvider: @escaping (@Sendable() -> String?) = { nil },
        tokenRefresher: (@Sendable() async throws -> String?)? = nil
    ) -> URLSessionNetworkService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return URLSessionNetworkService(session: session, tokenProvider: tokenProvider, tokenRefresher: tokenRefresher)
    }

    private func makeURL() -> URL {
        URL(string: "https://test.example.com/endpoint")!
    }

    private func makeRequest() -> URLRequest {
        URLRequest(url: makeURL())
    }

    private func makeResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: makeURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - request<T> — success

    func test_request_200_decodesObject() async throws {
        struct Item: Decodable, Equatable { let id: Int; let name: String }
        let json = Data(#"{"id": 1, "name": "Test"}"#.utf8)
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 200), json) }

        let result = try await sut.request(Item.self, for: makeRequest())

        XCTAssertEqual(result, Item(id: 1, name: "Test"))
    }

    func test_request_200_decodesArray() async throws {
        struct Item: Decodable { let id: Int }
        let json = Data(#"[{"id":1},{"id":2},{"id":3}]"#.utf8)
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 200), json) }

        let result = try await sut.request([Item].self, for: makeRequest())

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.first?.id, 1)
    }

    // MARK: - request<T> — HTTP errors

    func test_request_401_throwsInvalidResponseWith401() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 401), Data()) }

        do {
            _ = try await sut.request(String.self, for: makeRequest())
            XCTFail("Expected NetworkError.invalidResponse to be thrown")
        } catch NetworkError.invalidResponse(let statusCode) {
            XCTAssertEqual(statusCode, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_request_404_throwsInvalidResponseWith404() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 404), Data()) }

        do {
            _ = try await sut.request(String.self, for: makeRequest())
            XCTFail("Expected throw")
        } catch NetworkError.invalidResponse(let statusCode) {
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_request_500_throwsInvalidResponseWith500() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 500), Data()) }

        do {
            _ = try await sut.request(String.self, for: makeRequest())
            XCTFail("Expected throw")
        } catch NetworkError.invalidResponse(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - request<T> — decoding errors

    func test_request_malformedJSON_throwsDecodingFailed() async {
        struct Item: Decodable { let id: Int }
        let badData = Data("not json at all".utf8)
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 200), badData) }

        do {
            _ = try await sut.request(Item.self, for: makeRequest())
            XCTFail("Expected NetworkError.decodingFailed")
        } catch NetworkError.decodingFailed {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_request_wrongJSONShape_throwsDecodingFailed() async {
        struct Item: Decodable { let id: Int }
        let json = Data(#"{"wrong_key": "value"}"#.utf8)
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 200), json) }

        do {
            _ = try await sut.request(Item.self, for: makeRequest())
            XCTFail("Expected NetworkError.decodingFailed")
        } catch NetworkError.decodingFailed {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Authorization header

    func test_request_withToken_addsAuthorizationHeader() async throws {
        struct Item: Decodable { let id: Int }
        let json = Data(#"{"id": 1}"#.utf8)
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (self.makeResponse(statusCode: 200), json)
        }
        let sutWithToken = makeSUT(tokenProvider: { "test-token-123" })

        _ = try await sutWithToken.request(Item.self, for: makeRequest())

        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token-123")
    }

    func test_request_withoutToken_omitsAuthorizationHeader() async throws {
        struct Item: Decodable { let id: Int }
        let json = Data(#"{"id": 1}"#.utf8)
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            return (self.makeResponse(statusCode: 200), json)
        }

        _ = try await sut.request(Item.self, for: makeRequest())

        XCTAssertNil(capturedRequest?.value(forHTTPHeaderField: "Authorization"))
    }

    // MARK: - requestVoid

    func test_requestVoid_204_doesNotThrow() async throws {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 204), Data()) }

        try await sut.requestVoid(for: makeRequest())
        // Reaching here = success
    }

    func test_requestVoid_200_doesNotThrow() async throws {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 200), Data()) }

        try await sut.requestVoid(for: makeRequest())
    }

    func test_requestVoid_404_throws() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 404), Data()) }

        do {
            try await sut.requestVoid(for: makeRequest())
            XCTFail("Expected throw")
        } catch NetworkError.invalidResponse(let statusCode) {
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_requestVoid_500_throws() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 500), Data()) }

        do {
            try await sut.requestVoid(for: makeRequest())
            XCTFail("Expected throw")
        } catch NetworkError.invalidResponse(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - URLRequest+JSON convenience

    func test_postRequest_setsHTTPMethodPOST() throws {
        struct Body: Encodable { let name: String }
        let request = try URLRequest.post(url: makeURL(), body: Body(name: "test"))
        XCTAssertEqual(request.httpMethod, "POST")
    }

    func test_postRequest_setsContentTypeApplicationJSON() throws {
        struct Body: Encodable { let name: String }
        let request = try URLRequest.post(url: makeURL(), body: Body(name: "test"))
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func test_postRequest_encodesBodyAsJSON() throws {
        struct Body: Encodable, Decodable { let name: String }
        let request = try URLRequest.post(url: makeURL(), body: Body(name: "Sebas"))
        let decoded = try JSONDecoder().decode(Body.self, from: XCTUnwrap(request.httpBody))
        XCTAssertEqual(decoded.name, "Sebas")
    }

    func test_putRequest_setsHTTPMethodPUT() throws {
        struct Body: Encodable { let value: Int }
        let request = try URLRequest.put(url: makeURL(), body: Body(value: 42))
        XCTAssertEqual(request.httpMethod, "PUT")
    }

    func test_patchRequest_setsHTTPMethodPATCH() throws {
        struct Body: Encodable { let value: Int }
        let request = try URLRequest.patch(url: makeURL(), body: Body(value: 1))
        XCTAssertEqual(request.httpMethod, "PATCH")
    }

    func test_deleteRequest_setsHTTPMethodDELETE() {
        let request = URLRequest.delete(url: makeURL())
        XCTAssertEqual(request.httpMethod, "DELETE")
    }

    func test_deleteRequest_hasNoBody() {
        let request = URLRequest.delete(url: makeURL())
        XCTAssertNil(request.httpBody)
    }

    // MARK: - Retry on 401

    func test_request_401_withRefresher_retriesAndReturnsSuccess() async throws {
        struct Item: Decodable, Equatable { let id: Int }
        let json = Data(#"{"id": 99}"#.utf8)
        var callCount = 0

        MockURLProtocol.requestHandler = { _ in
            callCount += 1
            if callCount == 1 {
                return (self.makeResponse(statusCode: 401), Data())
            }
            return (self.makeResponse(statusCode: 200), json)
        }

        let sutWithRefresher = makeSUT(tokenRefresher: { "refreshed-token" })

        let result = try await sutWithRefresher.request(Item.self, for: makeRequest())

        XCTAssertEqual(result, Item(id: 99))
        XCTAssertEqual(callCount, 2, "Should have made exactly 2 requests: original + retry")
    }

    func test_request_401_withRefresher_whenRefreshFails_propagatesError() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 401), Data()) }

        struct RefreshError: Error {}
        let sutWithFailingRefresher = makeSUT(tokenRefresher: { throw RefreshError() })

        do {
            _ = try await sutWithFailingRefresher.request(String.self, for: makeRequest())
            XCTFail("Expected error to be thrown")
        } catch is RefreshError {
            // expected — refresh error propagates to the caller
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_request_401_withRefresher_whenRefresherReturnsNil_throws401() async {
        MockURLProtocol.requestHandler = { _ in (self.makeResponse(statusCode: 401), Data()) }

        let sutWithNilRefresher = makeSUT(tokenRefresher: { nil })

        do {
            _ = try await sutWithNilRefresher.request(String.self, for: makeRequest())
            XCTFail("Expected NetworkError.invalidResponse to be thrown")
        } catch NetworkError.invalidResponse(let statusCode) {
            XCTAssertEqual(statusCode, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Concurrent 401 coalescing

    func test_concurrent401s_refreshCalledOnce() async throws {
        struct Item: Decodable, Equatable { let id: Int }
        let json = Data(#"{"id": 99}"#.utf8)

        // Counts server hits — both initial requests get 401, retries get 200
        nonisolated(unsafe) var serverCallCount = 0
        // Counts refresher invocations — this is what we're actually asserting
        nonisolated(unsafe) var refreshCallCount = 0

        MockURLProtocol.requestHandler = { _ in
            serverCallCount += 1
            // First two calls are the concurrent initial requests → both get 401
            // Subsequent calls are the retries after refresh → get 200
            if serverCallCount == 1 {
                return (self.makeResponse(statusCode: 401), Data())
            }
            return (self.makeResponse(statusCode: 200), json)
        }

        let sutWithRefresher = makeSUT(tokenRefresher: {
            refreshCallCount += 1
            return "refreshed-token"
        })

        // Launch both requests concurrently — no try/await at async let declaration
        async let firstResult = sutWithRefresher.request(Item.self, for: makeRequest())
        async let secondResult = sutWithRefresher.request(Item.self, for: makeRequest())

        let (first, second) = try await (firstResult, secondResult)

        XCTAssertEqual(first, Item(id: 99))
        XCTAssertEqual(second, Item(id: 99))
        // The key assertion: TokenRefreshCoordinator coalesced both 401s into a single refresh call
        XCTAssertEqual(refreshCallCount, 1, "Should call the refresher once even with concurrent 401s")
    }
}
