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

    // MARK: - Stubbed Results

    var fetchCardsResult: Result<[Card], ServerError> = .success([])
    var fetchTransactionsResult: Result<[Transaction], ServerError> = .success([])

    // MARK: - Captured Arguments

    var capturedCardIds: [String] = []

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

    // MARK: - Helpers

    func reset() {
        fetchCardsCallCount = 0
        fetchTransactionsCallCount = 0
        capturedCardIds = []
        fetchCardsResult = .success([])
        fetchTransactionsResult = .success([])
    }
}
