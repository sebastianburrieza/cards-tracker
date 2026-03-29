//  CardsListDeepLinkParser.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import Navigation

/// Parses push notifications and deep link URLs owned by the CardsList feature.
///
/// Registered at startup via ``AppRouter/registerAllDeepLinkParsers()``.
/// Returns `nil` for any trigger that doesn't belong to this feature,
/// allowing other parsers to handle it.
public struct CardsListDeepLinkParser: DeepLinkParserProtocol {

    // MARK: - Notification types owned by this feature

    private enum NotificationType: String {
        /// Sent when the user makes a purchase on a card.
        case purchase
    }

    // MARK: - URL hosts owned by this feature

    private enum URLHost: String {
        case cardsList = "cards-list"
    }

    private let routerService: any RouterServiceProtocol

    public init(routerService: any RouterServiceProtocol) {
        self.routerService = routerService
    }

    // MARK: - DeepLinkParserProtocol

    public func action(fromNotification userInfo: [AnyHashable: Any]) -> (any DeepLinkAction)? {
        guard
            let type = userInfo["type"] as? String,
            NotificationType(rawValue: type) != nil
        else { return nil }

        return CardsListDeepLinkAction(
            queryParameters: userInfo as? [String: Any] ?? [:],
            routerService: routerService
        )
    }

    public func action(fromURL url: URL) -> (any DeepLinkAction)? {
        guard
            let host = url.host,
            URLHost(rawValue: host) != nil
        else { return nil }

        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: Any]()) { $0[$1.name] = $1.value ?? "" } ?? [:]

        return CardsListDeepLinkAction(queryParameters: params, routerService: routerService)
    }
}
