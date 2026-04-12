//  CardsTransactionDetailDeepLinkAction.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import Navigation
import CardsTransactionDetailInterface

/// Executed when the app receives a push notification or deep link owned by the CardsTransactionDetail feature.
///
/// Navigates to the transaction detail screen via the injected ``RouterServiceProtocol``.
///
/// **Supported query parameters:**
/// - `transactionId` *(required)*: the transaction to display.
final class CardsTransactionDetailDeepLinkAction: DeepLinkAction {

    var queryParameters: [String: Any]
    private let routerService: any RouterServiceProtocol

    init(queryParameters: [String: Any], routerService: any RouterServiceProtocol) {
        self.queryParameters = queryParameters
        self.routerService = routerService
    }

    // MARK: - DeepLinkAction

    func performAction() async -> Result<[String: Any], any Error> {
        guard let transactionId = queryParameters["transactionId"] as? String else {
            return .success(queryParameters)
        }
        await routerService.navigate(
            to: CardsTransactionDetailRoute(transactionId: transactionId),
            navigationType: .push(true)
        )
        return .success(queryParameters)
    }
}
