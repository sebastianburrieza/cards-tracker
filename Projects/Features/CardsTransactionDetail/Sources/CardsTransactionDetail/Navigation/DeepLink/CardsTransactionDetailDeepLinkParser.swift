//  CardsTransactionDetailDeepLinkParser.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import Foundation
import Navigation

/// Parses push notifications and deep link URLs owned by the CardsTransactionDetail feature.
///
/// Registered at startup via ``AppRouter/registerAllDeepLinkParsers()``.
/// Returns `nil` for any trigger that doesn't belong to this feature,
/// allowing other parsers to handle it.
public struct CardsTransactionDetailDeepLinkParser: DeepLinkParserProtocol {

    // MARK: - Notification types owned by this feature

    private enum NotificationType: String {
        /// Sent when the user should be directed to a specific transaction.
        case transactionDetail = "transaction_detail"
    }

    // MARK: - URL hosts owned by this feature

    private enum URLHost: String {
        case transactionDetail = "transaction-detail"
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

        return CardsTransactionDetailDeepLinkAction(
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

        return CardsTransactionDetailDeepLinkAction(queryParameters: params, routerService: routerService)
    }
}
