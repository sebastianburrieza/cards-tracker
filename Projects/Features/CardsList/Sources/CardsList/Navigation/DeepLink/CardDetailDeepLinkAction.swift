//  CardDetailDeepLinkAction.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Factory
import Navigation
import CardsListInterface

/// Executed when the app receives a push notification or deep link targeting a specific card detail.
///
/// Fetches the card by ID from the repository, then navigates to ``CardDetailRoute``.
///
/// **Supported query parameters:**
/// - `cardId` *(required)*: the card to display.
final class CardDetailDeepLinkAction: DeepLinkAction {

    var queryParameters: [String: Any]
    private let routerService: any RouterServiceProtocol

    @Injected(\.cardsRepository) private var repository

    init(queryParameters: [String: Any], routerService: any RouterServiceProtocol) {
        self.queryParameters = queryParameters
        self.routerService = routerService
    }

    // MARK: - DeepLinkAction

    func performAction() async -> Result<[String: Any], any Error> {
        guard let cardId = queryParameters["cardId"] as? String else {
            return .failure(DeepLinkActionError.missingParameter("cardId"))
        }

        let result = await repository.fetchCard(id: cardId)

        switch result {
        case .success(let card):
            await routerService.navigate(
                to: CardDetailRoute(card: card),
                navigationType: .push(true)
            )
            return .success(queryParameters)
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Errors

private enum DeepLinkActionError: Error {
    case missingParameter(String)
}
