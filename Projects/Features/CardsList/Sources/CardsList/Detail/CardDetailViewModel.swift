//  CardDetailViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import Utilities
import Extensions
import CoreModels

/// Handles navigation events triggered from the card detail screen.
protocol CardDetailNavigationDelegate: AnyObject {
    /// Called when the user taps the back button.
    func navigateToPrevious()
    /// Called when the user taps a transaction row.
    func navigateToTransactionDetail(id: String)
}

@Observable
final class CardDetailViewModel {

    let card: Card

    var transactions: [CoreModels.Transaction] = []
    var isLoading: Bool = true
    var isFetching: Bool = false

    @ObservationIgnored
    weak var delegate: CardDetailNavigationDelegate?

    init(card: Card) {
        self.card = card
    }

    // MARK: - Data loading

    /// Fetches all transactions for this card from the remote endpoint.
    func fetchTransactions() async {
        await MainActor.run {
            isFetching = true
        }
    }

    // MARK: - Formatted values

    var formattedAmountUsed: String {
        let used = card.limit - card.available
        return NumberFormatter.formatValue(used, currency: .ARS, options: [.showCurrencySymbol])
    }

    var formattedRemaining: String {
        let formatted = NumberFormatter.formatValue(
            card.available,
            currency: .ARS,
            options: [.showCurrencySymbol, .maxFractionDigits(0)]
        )
        return "DETAIL_AVAILABLE".localized(formatted)
    }

}
