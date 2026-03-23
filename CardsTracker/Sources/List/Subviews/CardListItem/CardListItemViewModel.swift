//  CardListItemViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

final class CardListItemViewModel: ObservableObject {

    let card: Card

    init(card: Card) {
        self.card = card
    }

    var formattedAmountUsed: String {
        NumberFormatter.formatValue(
            NumberFormatter.getAmount(fromCent: card.amountUsedCents),
            currency: .ARS,
            options: [.showCurrencySymbol]
        )
    }

    var remainingCents: Int {
        max(card.limitCents - card.amountUsedCents, 0)
    }

    var formattedRemaining: String {
        NumberFormatter.formatValue(
            NumberFormatter.getAmount(fromCent: remainingCents),
            currency: .ARS,
            options: [.showCurrencySymbol, .maxFractionDigits(0)]
        )
    }

    var progress: Double {
        guard card.limitCents > 0 else { return 0 }
        return min(Double(card.amountUsedCents) / Double(card.limitCents), 1.0)
    }

    var progressColor: Color {
        card.daysUntilDue <= 10 ? Palette.orange.swiftUI : Palette.green.swiftUI
    }

    var dueDateLabel: String {
        card.daysUntilDue == 1
            ? CardsTrackerStrings.Card.DueDate.singular
            : CardsTrackerStrings.Card.DueDate.plural(card.daysUntilDue)
    }
}
