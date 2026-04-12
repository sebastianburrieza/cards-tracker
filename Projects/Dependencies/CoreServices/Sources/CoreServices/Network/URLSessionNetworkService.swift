//  URLSessionNetworkService.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Live ``NetworkServiceProtocol`` backed by `URLSession`.
///
/// Inject a custom `URLSession` in tests to avoid real network calls.
public final class URLSessionNetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let tokenProvider: () -> String?
    
    public init(session: URLSession = .shared, tokenProvider: @escaping () -> String? = { nil }) {
        self.session = session
        self.tokenProvider = tokenProvider
        
        let decoder = JSONDecoder()
        // Real backends typically send dates as Unix timestamps (seconds since epoch).
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder
    }
    
    // MARK: - NetworkServiceProtocol
    
    public func request<T: Decodable>(_ type: T.Type, for request: URLRequest) async throws -> T {
        var authorizedRequest = request
        if let token = tokenProvider() {
            authorizedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: authorizedRequest)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: 0)
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse(statusCode: http.statusCode)
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
}
