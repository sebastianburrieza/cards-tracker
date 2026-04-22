//  CardDetailViewModelTests.swift

import XCTest
import CoreModels
@testable import CardsList

final class CardDetailViewModelTests: XCTestCase {

    // MARK: - makeSUT

    private func makeSUT(
        limit: Int = 100_000,
        available: Int = 50_000
    ) -> CardDetailViewModel {
        CardDetailViewModel(card: .mock(limit: limit, available: available))
    }

    // MARK: - Initial State

    func test_init_storesCard() {
        let card = Card.mock(id: "card-abc")
        let sut = CardDetailViewModel(card: card)

        XCTAssertEqual(sut.card.id, "card-abc")
    }

    func test_init_isLoadingIsTrue() {
        let sut = makeSUT()

        XCTAssertTrue(sut.isLoading)
    }

    func test_init_isFetchingIsFalse() {
        let sut = makeSUT()

        XCTAssertFalse(sut.isFetching)
    }

    func test_init_transactionsIsEmpty() {
        let sut = makeSUT()

        XCTAssertTrue(sut.transactions.isEmpty)
    }

    // MARK: - fetchTransactions

    func test_fetchTransactions_setsisFetchingTrue() async {
        let sut = makeSUT()

        await sut.fetchTransactions()

        XCTAssertTrue(sut.isFetching)
    }

    func test_fetchTransactions_doesNotModifyTransactions() async {
        let sut = makeSUT()

        await sut.fetchTransactions()

        XCTAssertTrue(sut.transactions.isEmpty)
    }

    // MARK: - formattedAmountUsed

    func test_formattedAmountUsed_differsForDifferentUsedAmounts() {
        let lowUsed = makeSUT(limit: 100_000, available: 90_000)   // used = 10,000
        let highUsed = makeSUT(limit: 100_000, available: 10_000)  // used = 90,000

        XCTAssertNotEqual(lowUsed.amountConsumed, highUsed.amountConsumed)
    }

    func test_formattedAmountUsed_withZeroUsed_isSameAsAnotherZeroUsedCard() {
        // Two cards with limit == available both show the same "zero used" amount
        let sut1 = makeSUT(limit: 100_000, available: 100_000)
        let sut2 = makeSUT(limit: 200_000, available: 200_000)

        XCTAssertEqual(sut1.amountConsumed, sut2.amountConsumed)
    }

    func test_formattedAmountUsed_dependsOnAvailable_notJustLimit() {
        // Same limit, different available → different used amount
        let sut1 = makeSUT(limit: 100_000, available: 80_000) // used = 20,000
        let sut2 = makeSUT(limit: 100_000, available: 30_000) // used = 70,000

        XCTAssertNotEqual(sut1.amountConsumed, sut2.amountConsumed)
    }

    func test_formattedAmountUsed_dependsOnLimit_notJustAvailable() {
        // Same available, different limit → different used amount
        let sut1 = makeSUT(limit: 100_000, available: 50_000) // used = 50,000
        let sut2 = makeSUT(limit: 200_000, available: 50_000) // used = 150,000

        XCTAssertNotEqual(sut1.amountConsumed, sut2.amountConsumed)
    }

    // MARK: - formattedRemaining

    func test_formattedRemaining_isNotEmpty() {
        let sut = makeSUT(available: 50_000)

        XCTAssertFalse(sut.formattedRemaining.isEmpty)
    }

    func test_formattedRemaining_sameAvailable_producesSameString() {
        let sut1 = makeSUT(limit: 100_000, available: 60_000)
        let sut2 = makeSUT(limit: 200_000, available: 60_000)

        // formattedRemaining only reflects available, not limit
        XCTAssertEqual(sut1.formattedRemaining, sut2.formattedRemaining)
    }
}
