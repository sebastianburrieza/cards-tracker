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
    var isLoading: Bool = false
    
    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    @ObservationIgnored
    weak var delegate: CardDetailNavigationDelegate?

    init(card: Card) {
        self.card = card
    }

    // MARK: - Data loading

    /// Fetches all transactions for this card from the remote endpoint.
    func fetchTransactions() async {
        await MainActor.run { isLoading = true }

        let result = await repository.fetchTransactions(for: card.id)

        await MainActor.run {
            switch result {
            case .success(let transactions):
                self.transactions = transactions
            case .failure(let error):
                showError(error)
            }
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
    
    func showError(_ error: ServerError? = nil) {
        errorTitle = error?.title ?? "Algo salió mal"
        errorMessage = error?.message ?? "Por favor intenta de nuevo más tarde"
        isError = true
    }
}
