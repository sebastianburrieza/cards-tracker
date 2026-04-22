//  ListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import CoreModels
import ResourcesUI
import Extensions

/// Handles navigation events triggered from the cards list screen.
protocol ListNavigationDelegate: AnyObject {
    func navigateToDetail(card: Card)
    func navigateToAddCard()
}

@Observable
final class ListViewModel {

    var cards: [Card] = []
    var totalConsumed: Int = 0
    var totalAvailable: Int = 0
    var fontColor: Color = Palette.white.swiftUI
    
    var isLoading = true

    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    @ObservationIgnored
    weak var delegate: ListNavigationDelegate?

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
            isLoading = false
            switch result {
            case .success(let cards):
                self.cards = cards
                let consumed = cards.reduce(0) { $0 + max($1.limit - $1.available, 0) }
                let available = cards.reduce(0) { $0 + $1.available }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.totalConsumed = consumed
                    self?.totalAvailable = available
                }
            case .failure(let error):
                showError(error)
            }
        }
    }

    func showError(_ error: ServerError? = nil) {
        errorTitle = error?.title ?? "ERROR_TITLE_GENERIC".localized
        errorMessage = error?.message ?? "ERROR_MESSAGE_GENERIC".localized
        isError = true
    }
}
