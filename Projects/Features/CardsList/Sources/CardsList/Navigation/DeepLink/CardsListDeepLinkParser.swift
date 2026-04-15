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
        case list
        case cardDetail
    }

    // MARK: - URL hosts owned by this feature

    private enum URLHost: String {
        case cardsList = "cards-list"
        case cardDetail = "card-detail"
    }

    private let routerService: any RouterServiceProtocol

    public init(routerService: any RouterServiceProtocol) {
        self.routerService = routerService
    }

    // MARK: - DeepLinkParserProtocol

    public func action(fromNotification userInfo: [AnyHashable: Any]) -> (any DeepLinkAction)? {
        guard
            let type = userInfo["type"] as? String,
            let notificationType = NotificationType(rawValue: type)
        else { return nil }

        let params = userInfo as? [String: Any] ?? [:]

        switch notificationType {
        case .list:
            return CardsListDeepLinkAction(queryParameters: params, routerService: routerService)
        case .cardDetail:
            return CardDetailDeepLinkAction(queryParameters: params, routerService: routerService)
        }
    }

    public func action(fromURL url: URL) -> (any DeepLinkAction)? {
        guard
            let host = url.host,
            let urlHost = URLHost(rawValue: host)
        else { return nil }

        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: Any]()) { $0[$1.name] = $1.value ?? "" } ?? [:]

        switch urlHost {
        case .cardsList:
            return CardsListDeepLinkAction(queryParameters: params, routerService: routerService)
        case .cardDetail:
            return CardDetailDeepLinkAction(queryParameters: params, routerService: routerService)
        }
    }
}
