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
        switch progress {
        case 0.9...1:
            return Palette.red.swiftUI
        case 0.6...0.89:
            return Palette.orange.swiftUI
        default:
            return Palette.green.swiftUI
        }
    }

    var dueDateLabel: String {
        daysUntilDue == 1
            ? "DUEDATE_SINGULAR".localized
            : "DUEDATE_PLURAL".localized(daysUntilDue)
    }

    // MARK: - Card info

    var bankName: String { card.bankName }

    var typeLabel: String {
        switch card.type {
        case .creditPlastic, .creditVirtual: return "Crédito"
        case .debitPlastic, .debitVirtual: return "Débito"
        case .skeleton, .failure: return ""
        }
    }

    var maskedLastFour: String {
        card.lastFourDigits.isEmpty ? "" : "•••• \(card.lastFourDigits)"
    }

    // MARK: - Accessibility

    var accessibilityLabel: String {
        "\(card.bankName). Consumos: \(formattedAmountUsed). Disponible: \(formattedRemaining). \(dueDateLabel)."
    }

    // MARK: - Private helpers

    private var amountUsedCents: Int {
        max(card.limit - card.available, 0)
    }

    private var daysUntilDue: Int {
        max(Calendar.current.dateComponents([.day], from: .now, to: card.dueDate).day ?? 0, 0)
    }
}
