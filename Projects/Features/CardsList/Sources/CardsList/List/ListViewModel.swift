//  ListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import CoreModels

/// Handles navigation events triggered from the cards list screen.
protocol ListNavigationDelegate: AnyObject {
    /// Called when the user selects a card to view its detail.
    func navigateToDetail(card: Card)
    /// Called when a data operation fails.
    func showError(_ error: ServerError)
}

@Observable
final class ListViewModel {

    var cards: [Card] = []
    var isLoading = false

    @Injected(\.cardsRepository) @ObservationIgnored private var repository

    weak var delegate: ListNavigationDelegate?

    // MARK: - Data loading

    /// Fetches the cards list from the remote endpoint.
    /// Publishes results to ``cards`` or forwards the error to the delegate.
    func fetchCards() async {
        await MainActor.run { isLoading = true }
        defer { isLoading = false }

        let result = await repository.fetchCards()

        await MainActor.run {
            switch result {
            case .success(let cards):
                self.cards = cards
            case .failure(let error):
                delegate?.showError(error)
            }
        }
    }
}
