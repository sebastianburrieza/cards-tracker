//  DeepLinkHandler.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Central service that receives and dispatches deep links and push notifications.
///
/// Feature modules register their ``DeepLinkParserProtocol`` at startup via
/// ``AppRouter/registerAllDeepLinkParsers()``. When an external trigger arrives,
/// the handler iterates registered parsers until one produces a ``DeepLinkAction``,
/// then executes it immediately or stores it as pending for cold-start processing.
///
/// **Cold start flow** (app killed → user taps notification):
/// ```
/// AppDelegate.didFinishLaunching → deepLinkHandler.handle(notification:)
/// SceneDelegate.willConnectTo    → deepLinkHandler.processPendingIfNeeded()
/// ```
///
/// **Foreground flow** (app running → notification received):
/// ```
/// UNUserNotificationCenterDelegate → deepLinkHandler.process(notification:)
/// ```
public final class DeepLinkHandler: DeepLinkHandlerProtocol {

    private var parsers: [any DeepLinkParserProtocol] = []

    /// Stores the resolved action when the app is not yet ready to navigate (cold start).
    private var pendingAction: (any DeepLinkAction)?

    public init() {}

    // MARK: - Registration

    /// Registers a parser for a feature module.
    /// Called from ``AppRouter/registerAllDeepLinkParsers()``.
    public func register(parser: any DeepLinkParserProtocol) {
        parsers.append(parser)
    }

    // MARK: - Handling

    /// Resolves a push notification payload into an action and stores it as pending.
    /// Use ``processPendingIfNeeded()`` to execute it once the app is ready.
    public func handle(notification userInfo: [AnyHashable: Any]) {
        pendingAction = parsers.lazy.compactMap { $0.action(fromNotification: userInfo) }.first
    }

    /// Resolves a deep link URL into an action and stores it as pending.
    /// Use ``processPendingIfNeeded()`` to execute it once the app is ready.
    public func handle(url: URL) {
        pendingAction = parsers.lazy.compactMap { $0.action(fromURL: url) }.first
    }

    // MARK: - Execution

    /// Executes the pending action if one exists, then clears it.
    /// Should be called after the app is fully initialised (from `SceneDelegate.willConnectTo`).
    @MainActor
    @discardableResult
    public func processPendingIfNeeded() async -> Result<[String: Any], any Error>? {
        guard let action = pendingAction else { return nil }
        pendingAction = nil
        return await action.performAction()
    }

    /// Immediately resolves and executes a push notification.
    /// Use when the app is already running and the navigation stack is ready.
    @MainActor
    @discardableResult
    public func process(notification userInfo: [AnyHashable: Any]) async -> Result<[String: Any], any Error>? {
        handle(notification: userInfo)
        return await processPendingIfNeeded()
    }

    /// Immediately resolves and executes a deep link URL.
    /// Use when the app is already running and the navigation stack is ready.
    @MainActor
    @discardableResult
    public func process(url: URL) async -> Result<[String: Any], any Error>? {
        handle(url: url)
        return await processPendingIfNeeded()
    }
}
