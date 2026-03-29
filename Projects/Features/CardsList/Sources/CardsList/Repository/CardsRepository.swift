//  CardsRepository.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import Factory
import CoreServices

/// Live ``CardsRepositoryProtocol`` implementation backed by ``NetworkServiceProtocol``.
///
/// Both endpoints point to GitHub raw JSON files — a zero-infrastructure mock backend
/// that still exercises the full HTTP + decoding stack.
///
/// Swap the URLs for a real API without touching any feature-layer code.
final class CardsRepository: CardsRepositoryProtocol {

    private enum Endpoint {
        static let cards = URL(
            string: "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main/MockData/cards.json"
        )!
        static let transactions = URL(
            string: "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main/MockData/transactions.json"
        )!
    }

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - CardsRepositoryProtocol

    func fetchCards() async throws -> [Card] {
        try await networkService.fetch([Card].self, from: Endpoint.cards)
    }

    func fetchTransactions(for cardId: String) async throws -> [Transaction] {
        let all = try await networkService.fetch([Transaction].self, from: Endpoint.transactions)
        return all.filter { $0.cardId == cardId }
    }
}

// MARK: - Container

extension Container {

    /// Singleton cards repository for the CardsList feature.
    ///
    /// Override in unit tests:
    /// ```swift
    /// Container.shared.cardsRepository.register { MockCardsRepository() }
    /// ```
    var cardsRepository: Factory<any CardsRepositoryProtocol> {
        self { CardsRepository(networkService: self.networkService()) }.singleton
    }
}
