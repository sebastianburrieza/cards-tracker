//  URLSessionNetworkService.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Live ``NetworkServiceProtocol`` backed by `URLSession`.
///
/// Inject a custom `URLSession` in tests to avoid real network calls.
public final class URLSessionNetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        // Real backends typically send dates as Unix timestamps (seconds since epoch).
        // e.g. { "date": 1773100800 }
        decoder.dateDecodingStrategy = .secondsSince1970
        self.decoder = decoder
    }

    // MARK: - NetworkServiceProtocol

    public func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)

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

