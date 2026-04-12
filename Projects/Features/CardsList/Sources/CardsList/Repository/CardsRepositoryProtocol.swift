//  CardsRepositoryProtocol.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import CoreModels

/// Defines the data access interface for the CardsList feature.
///
/// Cards and transactions are stored in separate collections.
/// Transactions are fetched on demand per card and filtered by `cardId`.
///
/// Conform to this protocol to replace the live implementation with a mock in unit tests:
/// ```swift
/// Container.shared.cardsRepository.register { MockCardsRepository() }
/// ```
protocol CardsRepositoryProtocol {

    /// Fetches all cards for the current user.
    func fetchCards() async -> Result<[Card], ServerError>

    /// Fetches all transactions that belong to the given card.
    ///
    /// Retrieves the full transactions collection and filters by `cardId` client-side.
    /// - Parameter cardId: The `id` of the card (UUID string).
    func fetchTransactions(for cardId: String) async -> Result<[Transaction], ServerError>
}
