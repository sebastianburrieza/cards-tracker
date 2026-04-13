//  URLRequest+JSON.swift
//  Created by Sebastian Burrieza on 13/04/2026.

import Foundation

public extension URLRequest {

    /// Creates a POST request with a JSON-encoded body.
    ///
    /// - Parameters:
    ///   - url: The endpoint URL.
    ///   - body: An `Encodable` value to serialize as JSON.
    ///   - encoder: The encoder to use. Defaults to a plain `JSONEncoder`.
    /// - Throws: `EncodingError` if the body cannot be serialized.
    static func post<B: Encodable>(url: URL, body: B, encoder: JSONEncoder = .init()) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return request
    }

    /// Creates a PUT request with a JSON-encoded body.
    static func put<B: Encodable>(url: URL, body: B, encoder: JSONEncoder = .init()) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return request
    }

    /// Creates a PATCH request with a JSON-encoded body.
    static func patch<B: Encodable>(url: URL, body: B, encoder: JSONEncoder = .init()) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return request
    }

    /// Creates a DELETE request.
    static func delete(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return request
    }
}
