//  CardListItemViewModelTests.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import XCTest
@testable import CardsTracker

final class CardListItemViewModelTests: XCTestCase {

    // MARK: - remainingCents

    func test_remainingCents_returnsCorrectValue() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 3000, limitCents: 10000))
        XCTAssertEqual(sut.remainingCents, 7000)
    }

    func test_remainingCents_whenUsedExceedsLimit_returnsZero() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 15000, limitCents: 10000))
        XCTAssertEqual(sut.remainingCents, 0)
    }

    func test_remainingCents_whenUsedEqualsLimit_returnsZero() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 10000, limitCents: 10000))
        XCTAssertEqual(sut.remainingCents, 0)
    }

    // MARK: - progress

    func test_progress_returnsCorrectRatio() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 5000, limitCents: 10000))
        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.001)
    }

    func test_progress_whenLimitIsZero_returnsZero() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 0, limitCents: 0))
        XCTAssertEqual(sut.progress, 0)
    }

    func test_progress_whenUsedExceedsLimit_cappedAtOne() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 20000, limitCents: 10000))
        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.001)
    }

    func test_progress_whenUsedEqualsLimit_returnsOne() {
        let sut = CardListItemViewModel(card: makeCard(amountUsedCents: 10000, limitCents: 10000))
        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.001)
    }

    // MARK: - progressColor

    func test_progressColor_whenDaysUntilDueIsLessThanTen_returnsOrange() {
        let sut = CardListItemViewModel(card: makeCard(daysUntilDue: 7))
        XCTAssertEqual(sut.progressColor, Palette.orange.swiftUI)
    }

    func test_progressColor_whenDaysUntilDueIsEqualToTen_returnsOrange() {
        let sut = CardListItemViewModel(card: makeCard(daysUntilDue: 10))
        XCTAssertEqual(sut.progressColor, Palette.orange.swiftUI)
    }

    func test_progressColor_whenDaysUntilDueIsGreaterThanTen_returnsGreen() {
        let sut = CardListItemViewModel(card: makeCard(daysUntilDue: 16))
        XCTAssertEqual(sut.progressColor, Palette.green.swiftUI)
    }

    func test_progressColor_boundaryAtEleven_returnsGreen() {
        let sut = CardListItemViewModel(card: makeCard(daysUntilDue: 11))
        XCTAssertEqual(sut.progressColor, Palette.green.swiftUI)
    }

    // MARK: - dueDateLabel

    func test_dueDateLabel_whenOneDayLeft_returnsSingular() {
        let sut = CardListItemViewModel(card: makeCard(daysUntilDue: 1))
        XCTAssertEqual(sut.dueDateLabel, CardsTrackerStrings.Card.DueDate.singular)
    }

    func test_dueDateLabel_whenMultipleDaysLeft_returnsPlural() {
        let sut = CardListItemViewModel(card: makeCard(daysUntilDue: 7))
        XCTAssertEqual(sut.dueDateLabel, CardsTrackerStrings.Card.DueDate.plural(7))
    }
    
    // MARK: - Helpers

    private func makeCard(
        amountUsedCents: Int = 0,
        limitCents: Int = 100_00,
        daysUntilDue: Int = 15
    ) -> Card {
        Card(
            id: UUID(),
            type: .creditPlastic,
            color: .GREEN,
            hexa: nil,
            holderName: "Test User",
            amountUsedCents: amountUsedCents,
            limitCents: limitCents,
            daysUntilDue: daysUntilDue
        )
    }
}
