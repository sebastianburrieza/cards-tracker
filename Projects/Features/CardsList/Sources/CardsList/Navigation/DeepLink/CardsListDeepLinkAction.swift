//  CardsListDeepLinkAction.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Navigation
import CardsListInterface

/// Executed when the app receives a push notification or deep link owned by the CardsList feature.
///
/// Navigates to the cards list screen via the injected ``RouterServiceProtocol``.
///
/// **Supported query parameters:**
/// - `cardId` *(optional)*: scrolls to or highlights a specific card after navigation.
final class CardsListDeepLinkAction: DeepLinkAction {

    var queryParameters: [String: Any]
    private let routerService: any RouterServiceProtocol

    init(queryParameters: [String: Any], routerService: any RouterServiceProtocol) {
        self.queryParameters = queryParameters
        self.routerService = routerService
    }

    // MARK: - DeepLinkAction

    func performAction() async -> Result<[String: Any], any Error> {
        await routerService.navigate(to: CardsListRoute(), navigationType: .push(true))
        return .success(queryParameters)
    }
}
