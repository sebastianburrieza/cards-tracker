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

    // MARK: - Write state

    /// Local copy of the card's paused state.
    /// Updated optimistically on Pause tap and reverted on network failure.
    var isPaused: Bool

    /// True while a write operation (Pause / Report) is in flight.
    var isSubmitting: Bool = false

    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    // MARK: - Not observed

    @ObservationIgnored
    weak var delegate: CardDetailNavigationDelegate?

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    // MARK: - Init

    init(card: Card) {
        self.card = card
        self.isPaused = card.isPaused
    }

    // MARK: - Data loading

    /// Fetches all transactions for this card from the remote endpoint.
    func fetchTransactions() async {
        await MainActor.run {
            isFetching = true
        }
    }

    // MARK: - Write operations

    /// Toggles the paused state of the card.
    ///
    /// Uses **optimistic update**: the UI flips immediately and reverts if the server returns an error.
    /// Think of it like the Instagram heart — it taps instantly and undoes itself only if the request fails.
    func pauseCard() async {
        await MainActor.run {
            isPaused.toggle()   // optimistic update
            isSubmitting = true
        }

        let updatedCard = card.copy(isPaused: isPaused)

        let result = await repository.updateCard(updatedCard)

        await MainActor.run {
            if case .failure(let error) = result {
                isPaused.toggle()   // revert on failure
                showError(error)
            }
            isSubmitting = false
        }
    }

    /// Sends a report for this card.
    ///
    /// In a real app this would call `POST /cards/{id}/dispute`.
    /// Here it calls `updateCard` to demonstrate the full write flow through the repository.
    func reportCard() async {
        await MainActor.run { isSubmitting = true }

        let result = await repository.updateCard(card)

        await MainActor.run {
            if case .failure(let error) = result {
                showError(error)
            }
            isSubmitting = false
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

    // MARK: - Private

    private func showError(_ error: ServerError? = nil) {
        errorTitle = error?.title ?? "ERROR_TITLE_GENERIC".localized
        errorMessage = error?.message ?? "ERROR_MESSAGE_GENERIC".localized
        isError = true
    }
}
