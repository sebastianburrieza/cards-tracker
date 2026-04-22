//  AuthService.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

public protocol AuthServiceProtocol: Sendable {
    var isLoggedIn: Bool { get }
    func hasCredentials() -> Bool
    func saveCredentials(password: String) throws
    func login(password: String) -> Bool
    func logout()
}

public final class AuthService: @unchecked Sendable, AuthServiceProtocol {

    private enum Keys {
        static let password = "com.cardsTracker.auth.password"
        static let isLoggedIn = "com.cardsTracker.auth.isLoggedIn"
    }

    private let keychain: any KeychainServiceProtocol
    private let userDefaults: UserDefaults

    public init(
        keychain: any KeychainServiceProtocol = KeychainService(),
        userDefaults: UserDefaults = .standard
    ) {
        self.keychain = keychain
        self.userDefaults = userDefaults
    }

    public var isLoggedIn: Bool {
        userDefaults.bool(forKey: Keys.isLoggedIn)
    }

    public func hasCredentials() -> Bool {
        keychain.read(key: Keys.password) != nil
    }

    public func saveCredentials(password: String) throws {
        try keychain.save(key: Keys.password, value: password)
    }

    @discardableResult
    public func login(password: String) -> Bool {
        guard let stored = keychain.read(key: Keys.password),
              stored == password else {
            return false
        }
        userDefaults.set(true, forKey: Keys.isLoggedIn)
        return true
    }

    public func logout() {
        userDefaults.set(false, forKey: Keys.isLoggedIn)
    }
}
