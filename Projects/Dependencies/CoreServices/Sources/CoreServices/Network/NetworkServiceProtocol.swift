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

    /// Executes `request` and decodes the response body as `T`.
    ///
    /// - Throws: ``NetworkError`` on HTTP or decoding failures.
    func request<T: Decodable>(_ type: T.Type, for request: URLRequest) async throws -> T

    /// Executes `request` and discards the response body.
    ///
    /// Use for DELETE or any endpoint that returns no body (e.g. 204 No Content).
    /// - Throws: ``NetworkError`` on non-2xx status codes.
    func requestVoid(for request: URLRequest) async throws
}
