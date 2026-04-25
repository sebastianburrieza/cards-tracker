//  URLSessionNetworkService.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Live ``NetworkServiceProtocol`` backed by `URLSession`.
///
/// Inject a custom `URLSession` in tests to avoid real network calls:
/// ```swift
/// let config = URLSessionConfiguration.ephemeral
/// config.protocolClasses = [MockURLProtocol.self]
/// let sut = URLSessionNetworkService(session: URLSession(configuration: config))
/// ```
public final class URLSessionNetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: @Sendable () -> String?

    /// Optional async closure called on a 401 response to obtain a refreshed token.
    /// When present, the original request is retried once with the new token.
    /// When `nil`, a 401 is propagated immediately as ``NetworkError/invalidResponse(statusCode:)``.
    ///
    /// - Note: Concurrent 401s are coalesced by ``TokenRefreshCoordinator`` — only one
    ///   refresh call is ever in flight at a time, regardless of how many requests fail simultaneously.
    private let tokenRefresher: (@Sendable () async throws -> String?)?
    private let refreshCoordinator = TokenRefreshCoordinator()

    public init(
        session: URLSession = .shared,
        tokenProvider: @Sendable @escaping () -> String? = { nil },
        tokenRefresher: (@Sendable () async throws -> String?)? = nil
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
        self.tokenRefresher = tokenRefresher

        let decoder = JSONDecoder()
        // Real backends typically send dates as Unix timestamps (seconds since epoch).
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder
    }

    // MARK: - NetworkServiceProtocol

    public func request<T: Decodable>(_ type: T.Type, for request: URLRequest) async throws -> T {
        let (data, _) = try await execute(request)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }

    public func requestVoid(for request: URLRequest) async throws {
        _ = try await execute(request)
    }

    // MARK: - Private

    /// Executes the request with the current token. On 401, attempts a token refresh
    /// and retries once if a `tokenRefresher` is configured.
    ///
    /// Concurrent 401s are serialized by ``TokenRefreshCoordinator``:
    /// only one refresh runs at a time, all waiting requests reuse the result.
    private func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            return try await performAuthorized(request, token: tokenProvider())
        } catch NetworkError.invalidResponse(let statusCode) where statusCode == 401 {
            guard let refresher = tokenRefresher else {
                throw NetworkError.invalidResponse(statusCode: 401)
            }
            try Task.checkCancellation()
            guard let newToken = try await refreshCoordinator.refresh(using: refresher) else {
                // Refresher ran but returned no token — propagate the original 401.
                throw NetworkError.invalidResponse(statusCode: 401)
            }
            return try await performAuthorized(request, token: newToken)
        }
    }

    /// Attaches the Bearer token (if any), fires the request, and validates the HTTP status.
    private func performAuthorized(_ request: URLRequest, token: String?) async throws -> (Data, HTTPURLResponse) {
        var authorized = request
        if let token {
            authorized.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: authorized)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: 0)
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: http.statusCode)
        }

        return (data, http)
    }
}
