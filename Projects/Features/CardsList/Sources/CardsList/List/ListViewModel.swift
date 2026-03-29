//  ListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory

/// Handles navigation events triggered from the cards list screen.
protocol ListNavigationDelegate: AnyObject {
    /// Called when the user selects a card to view its detail.
    func navigateToDetail(card: Card)
}

final class ListViewModel: ObservableObject {

    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Injected(\.cardsRepository) private var repository

    weak var delegate: ListNavigationDelegate?

    // MARK: - Data loading

    /// Fetches the cards list from the remote endpoint.
    /// Publishes results to ``cards`` and any failure message to ``errorMessage``.
    func fetchCards() async {
        await MainActor.run {
            isLoading = true
        }
        errorMessage = nil
        do {
            cards = try await repository.fetchCards()
        } catch {
            errorMessage = error.localizedDescription
        }
        await MainActor.run {
            isLoading = false
        }
    }
}
