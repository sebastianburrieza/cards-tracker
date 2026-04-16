//  CardListItemViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import CoreModels
import ResourcesUI
import Utilities
import Extensions

@Observable
final class CardListItemViewModel {

    let card: Card

    init(card: Card) {
        self.card = card
    }

    // MARK: - Formatted values

    var formattedAmountUsed: String {
        NumberFormatter.formatValue(amountUsedCents, currency: .ARS, options: [.showCurrencySymbol])
    }

    var formattedRemaining: String {
        NumberFormatter.formatValue(card.available, currency: .ARS, options: [.showCurrencySymbol, .maxFractionDigits(0)])
    }

    var progress: Double {
        guard card.limit > 0 else { return 0 }
        return min(Double(amountUsedCents) / Double(card.limit), 1.0)
    }

    var progressColor: Color {
        daysUntilDue <= 10 ? Palette.orange.swiftUI : Palette.green.swiftUI
    }

    var dueDateLabel: String {
        daysUntilDue == 1
            ? "DUEDATE_SINGULAR".localized
            : "DUEDATE_PLURAL".localized(daysUntilDue)
    }

    // MARK: - Accessibility

    /// A single string VoiceOver reads aloud for the whole card row.
    var accessibilityLabel: String {
        "\(card.holderName). Consumos: \(formattedAmountUsed). Disponible: \(formattedRemaining). \(dueDateLabel)."
    }

    // MARK: - Private helpers

    private var amountUsedCents: Int {
        max(card.limit - card.available, 0)
    }

    private var daysUntilDue: Int {
        max(Calendar.current.dateComponents([.day], from: .now, to: card.dueDate).day ?? 0, 0)
    }
}
