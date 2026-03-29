//  NetworkError.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Errors that can be thrown by any ``NetworkServiceProtocol`` implementation.
public enum NetworkError: Error, LocalizedError {

    /// The provided URL string could not be parsed into a valid `URL`.
    case invalidURL

    /// The server returned a non-2xx HTTP status code.
    case invalidResponse(statusCode: Int)

    /// The response body could not be decoded into the expected type.
    case decodingFailed(underlying: Error)

    /// An unexpected error occurred (e.g. no network connection).
    case unknown(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse(let code):
            return "Server returned status \(code)."
        case .decodingFailed(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
