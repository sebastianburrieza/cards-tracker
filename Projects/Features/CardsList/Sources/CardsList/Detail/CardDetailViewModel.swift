//  CardDetailViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import Utilities
import Extensions

/// Handles navigation events triggered from the card detail screen.
protocol CardDetailNavigationDelegate: AnyObject {
    /// Called when the user taps the back button.
    func navigateToPrevious()
}

final class CardDetailViewModel: ObservableObject {

    let card: Card

    @Published var transactions: [Transaction] = []
    @Published var isLoading = false

    @Injected(\.cardsRepository) private var repository

    weak var delegate: CardDetailNavigationDelegate?

    init(card: Card) {
        self.card = card
    }

    // MARK: - Data loading

    /// Fetches all transactions for this card from the remote endpoint.
    func fetchTransactions() async {
        await MainActor.run {
            isLoading = true
        }
        
        transactions = (try? await repository.fetchTransactions(for: card.id)) ?? []
        
        await MainActor.run {
            isLoading = false
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
        return CardsListStrings.Card.Detail.disponible(formatted)
    }
}
