//  NetworkServiceProtocol.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Defines a minimal interface for making HTTP requests and decoding JSON responses.
///
/// Conform to this protocol to swap the live implementation with a mock in unit tests:
/// ```swift
/// Container.shared.networkService.register { MockNetworkService() }
/// ```
public protocol NetworkServiceProtocol {

    /// Fetches data from `url` and decodes it as `T`.
    ///
    /// - Throws: ``NetworkError`` on HTTP or decoding failures.
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}
