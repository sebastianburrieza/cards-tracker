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

    // MARK: - Read

    /// Fetches all cards for the current user.
    func fetchCards() async -> Result<[Card], ServerError>

    /// Fetches a single card by its identifier.
    ///
    /// - Parameter id: The `id` of the card (UUID string).
    func fetchCard(id: String) async -> Result<Card, ServerError>

    /// Fetches a page of transactions, optionally filtered by card.
    ///
    /// Uses cursor-based pagination. Pass an empty string for the first page.
    /// The returned `TransactionsPage.cursor` holds the next-page cursor, or `nil` when all pages have been loaded.
    /// - Parameters:
    ///   - cursor: Opaque pagination cursor. Pass `""` to start from the beginning.
    ///   - cardId: Optional card filter. Pass `nil` to fetch transactions across all cards.
    ///   - pageSize: Number of transactions to return per page.
    func fetchTransactions(cursor: String, cardId: String?, pageSize: Int) async -> Result<TransactionsPage, ServerError>

    // MARK: - Write

    /// Creates a new card and returns the server-persisted version.
    ///
    /// - Parameter card: The card to create. In a real API the server assigns the final `id`.
    func createCard(_ card: Card) async -> Result<Card, ServerError>

    /// Replaces an existing card with the provided values and returns the updated version.
    ///
    /// - Parameter card: The card to update. Must have a valid `id`.
    func updateCard(_ card: Card) async -> Result<Card, ServerError>

    /// Deletes the card with the given identifier.
    ///
    /// - Parameter cardId: The `id` of the card to delete.
    func deleteCard(id: String) async -> Result<Void, ServerError>
}
