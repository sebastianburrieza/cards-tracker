//  CardsRepositoryProtocol.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

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
    /// - Throws: ``NetworkError`` on HTTP or decoding failures.
    func fetchCards() async throws -> [Card]

    /// Fetches all transactions that belong to the given card.
    ///
    /// Retrieves the full transactions collection and filters by `cardId` client-side.
    /// - Parameter cardId: The `id` of the card (UUID string).
    /// - Throws: ``NetworkError`` on HTTP or decoding failures.
    func fetchTransactions(for cardId: String) async throws -> [Transaction]
}
