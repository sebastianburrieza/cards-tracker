//  ListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import CoreModels
import Extensions

/// Handles navigation events triggered from the cards list screen.
protocol ListNavigationDelegate: AnyObject {
    func navigateToDetail(card: Card)
    func navigateToAddCard()
}

@Observable
final class ListViewModel {

    var cards: [Card] = []
    var isLoading = true

    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    @ObservationIgnored
    weak var delegate: ListNavigationDelegate?

    // MARK: - Aggregates

    var formattedTotalConsumed: String {
        NumberFormatter.formatValue(totalConsumed, currency: .ARS, options: [.showCurrencySymbol])
    }

    var formattedTotalAvailable: String {
        NumberFormatter.formatValue(totalAvailable, currency: .ARS, options: [.showCurrencySymbol, .maxFractionDigits(0)])
    }

    private var totalConsumed: Int {
        cards.reduce(0) { $0 + max($1.limit - $1.available, 0) }
    }

    private var totalAvailable: Int {
        cards.reduce(0) { $0 + $1.available }
    }

    // MARK: - Navigation

    func navigateToAddCard() {
        delegate?.navigateToAddCard()
    }

    // MARK: - Data loading

    /// Fetches the cards list from the remote endpoint.
    func fetchCards() async {
        await MainActor.run { isLoading = true }

        let result = await repository.fetchCards()

        await MainActor.run {
            switch result {
            case .success(let cards):
                self.cards = cards
            case .failure(let error):
                showError(error)
            }
            isLoading = false
        }
    }

    func showError(_ error: ServerError? = nil) {
        errorTitle = error?.title ?? "ERROR_TITLE_GENERIC".localized
        errorMessage = error?.message ?? "ERROR_MESSAGE_GENERIC".localized
        isError = true
    }
}
