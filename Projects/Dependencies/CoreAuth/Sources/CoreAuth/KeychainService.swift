//  KeychainService.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Security
import Foundation

public protocol KeychainServiceProtocol: Sendable {
    func save(key: String, value: String) throws
    func read(key: String) -> String?
    func delete(key: String) throws
}

public enum KeychainError: Error {
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)
}

public final class KeychainService: KeychainServiceProtocol {

    public init() {}

    public func save(key: String, value: String) throws {
        let data = Data(value.utf8)

        // Delete any existing entry before saving to avoid duplicate item errors
        try? delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    public func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    public func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}
