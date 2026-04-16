//  MockCardsRepository.swift

import Foundation
import CoreModels
@testable import CardsList

/// Mock implementation of `CardsRepositoryProtocol` for unit testing.
/// Allows stubbing return values and tracking call counts.
final class MockCardsRepository: CardsRepositoryProtocol {

    // MARK: - Call Tracking

    var fetchCardsCallCount = 0
    var fetchTransactionsCallCount = 0
    var createCardCallCount = 0
    var updateCardCallCount = 0
    var deleteCardCallCount = 0

    // MARK: - Captured Arguments

    var capturedCardIds: [String] = []
    var capturedCreatedCard: Card?
    var capturedUpdatedCard: Card?
    var capturedDeletedId: String?

    // MARK: - Stubbed Results

    var fetchCardsResult: Result<[Card], ServerError> = .success([])
    var fetchTransactionsResult: Result<[Transaction], ServerError> = .success([])
    var createCardResult: Result<Card, ServerError> = .success(.mock())
    var updateCardResult: Result<Card, ServerError> = .success(.mock())
    var deleteCardResult: Result<Void, ServerError> = .success(())

    // MARK: - Protocol Implementation

    func fetchCards() async -> Result<[Card], ServerError> {
        fetchCardsCallCount += 1
        return fetchCardsResult
    }

    func fetchTransactions(for cardId: String) async -> Result<[Transaction], ServerError> {
        fetchTransactionsCallCount += 1
        capturedCardIds.append(cardId)
        return fetchTransactionsResult
    }

    func createCard(_ card: Card) async -> Result<Card, ServerError> {
        createCardCallCount += 1
        capturedCreatedCard = card
        return createCardResult
    }

    func updateCard(_ card: Card) async -> Result<Card, ServerError> {
        updateCardCallCount += 1
        capturedUpdatedCard = card
        return updateCardResult
    }

    func deleteCard(id: String) async -> Result<Void, ServerError> {
        deleteCardCallCount += 1
        capturedDeletedId = id
        return deleteCardResult
    }

    // MARK: - Helpers

    func reset() {
        fetchCardsCallCount = 0
        fetchTransactionsCallCount = 0
        createCardCallCount = 0
        updateCardCallCount = 0
        deleteCardCallCount = 0
        capturedCardIds = []
        capturedCreatedCard = nil
        capturedUpdatedCard = nil
        capturedDeletedId = nil
        fetchCardsResult = .success([])
        fetchTransactionsResult = .success([])
        createCardResult = .success(.mock())
        updateCardResult = .success(.mock())
        deleteCardResult = .success(())
    }
}
