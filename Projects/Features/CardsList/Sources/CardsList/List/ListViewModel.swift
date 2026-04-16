//  ListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import CoreModels

/// Handles navigation events triggered from the cards list screen.
protocol ListNavigationDelegate: AnyObject {
    /// Called when the user selects a card to view its detail.
    func navigateToDetail(card: Card)
}

@Observable
final class ListViewModel {

    var cards: [Card] = []
    var isLoading = false
    
    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    @ObservationIgnored
    weak var delegate: ListNavigationDelegate?

    // MARK: - Data loading

    /// Fetches the cards list from the remote endpoint.
    /// Publishes results to ``cards`` or forwards the error to the delegate.
    func fetchCards() async {
        await MainActor.run { isLoading = true }

        let result = await repository.fetchCards()

        await MainActor.run {
            switch result {
            case .success(let cards):
                self.cards = cards
                showError()
            case .failure(let error):
                showError(error)
            }
            isLoading = false
        }
    }
    
    func showError(_ error: ServerError? = nil) {
        errorTitle = error?.title ?? "Algo salió mal"
        errorMessage = error?.message ?? "Por favor intenta de nuevo más tarde"
        isError = true
    }
}
