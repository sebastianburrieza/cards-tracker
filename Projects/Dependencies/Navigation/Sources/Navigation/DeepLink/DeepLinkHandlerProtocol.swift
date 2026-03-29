//  DeepLinkHandlerProtocol.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Defines the interface for registering parsers and dispatching deep links
/// and push notifications throughout the app.
///
/// Conform to this protocol to replace ``DeepLinkHandler`` with a mock in unit tests.
public protocol DeepLinkHandlerProtocol {

    /// Registers a parser for a feature module.
    func register(parser: any DeepLinkParserProtocol)

    /// Resolves a push notification payload into an action and stores it as pending.
    func handle(notification userInfo: [AnyHashable: Any])

    /// Resolves a deep link URL into an action and stores it as pending.
    func handle(url: URL)

    /// Executes the pending action if one exists, then clears it.
    @MainActor
    @discardableResult
    func processPendingIfNeeded() async -> Result<[String: Any], any Error>?

    /// Immediately resolves and executes a push notification.
    @MainActor
    @discardableResult
    func process(notification userInfo: [AnyHashable: Any]) async -> Result<[String: Any], any Error>?

    /// Immediately resolves and executes a deep link URL.
    @MainActor
    @discardableResult
    func process(url: URL) async -> Result<[String: Any], any Error>?
}
