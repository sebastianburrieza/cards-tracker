//  DeepLinkParserProtocol.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Converts an external trigger (push notification payload or URL) into a ``DeepLinkAction``.
///
/// Each feature module that owns navigable destinations registers its own parser
/// in ``AppRouter/registerAllDeepLinkParsers()``.
/// Parsers return `nil` for triggers they don't own, allowing the ``DeepLinkHandler``
/// to iterate through all registered parsers until one matches.
///
/// **Example:**
/// ```swift
/// public struct CardsListDeepLinkParser: DeepLinkParserProtocol {
///     public func action(fromNotification userInfo: [AnyHashable: Any]) -> (any DeepLinkAction)? {
///         guard userInfo["type"] as? String == "purchase" else { return nil }
///         return CardsListDeepLinkAction(queryParameters: userInfo as? [String: Any] ?? [:])
///     }
/// }
/// ```
public protocol DeepLinkParserProtocol {

    /// Attempts to parse a push notification payload into a ``DeepLinkAction``.
    /// - Returns: A ``DeepLinkAction`` if this parser owns the notification, otherwise `nil`.
    func action(fromNotification userInfo: [AnyHashable: Any]) -> (any DeepLinkAction)?

    /// Attempts to parse a URL into a ``DeepLinkAction``.
    /// - Returns: A ``DeepLinkAction`` if this parser owns the URL, otherwise `nil`.
    func action(fromURL url: URL) -> (any DeepLinkAction)?
}
