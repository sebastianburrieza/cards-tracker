//  CardsRepository.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import Factory
import CoreModels
import CoreServices

/// Live ``CardsRepositoryProtocol`` implementation backed by ``NetworkServiceProtocol``.
///
/// Both read endpoints point to GitHub raw JSON files — a zero-infrastructure mock backend
/// that still exercises the full HTTP + decoding stack.
/// Write endpoints point to a placeholder base URL and will work once a real API is available.
///
/// Swap the URLs for a real API without touching any feature-layer code.
final class CardsRepository: CardsRepositoryProtocol {

    private enum Endpoint {
        // Read — GitHub raw JSON mock
        static let cards    = URL(string: "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main/MockData/cards.json")
        static let transactions = URL(string: "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main/MockData/transactions.json")

        // Write — replace with real API base URL when available
        static func card(id: String) -> URL? {
            URL(string: "https://api.cardstracker.com/cards/\(id)")
        }
        static var createCard: URL? {
            URL(string: "https://api.cardstracker.com/cards")
        }
    }

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - Read

    func fetchCards() async -> Result<[Card], ServerError> {
        guard let url = Endpoint.cards else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform { try await networkService.request([Card].self, for: URLRequest(url: url)) }
    }

    func fetchTransactions(for cardId: String) async -> Result<[Transaction], ServerError> {
        guard let url = Endpoint.transactions else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform {
            let all = try await networkService.request([Transaction].self, for: URLRequest(url: url))
            return all.filter { $0.cardId == cardId }
        }
    }

    // MARK: - Write

    func createCard(_ card: Card) async -> Result<Card, ServerError> {
        guard let url = Endpoint.createCard else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform {
            let request = try URLRequest.post(url: url, body: card)
            return try await networkService.request(Card.self, for: request)
        }
    }

    func updateCard(_ card: Card) async -> Result<Card, ServerError> {
        guard let url = Endpoint.card(id: card.id) else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform {
            let request = try URLRequest.put(url: url, body: card)
            return try await networkService.request(Card.self, for: request)
        }
    }

    func deleteCard(id: String) async -> Result<Void, ServerError> {
        guard let url = Endpoint.card(id: id) else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform {
            try await networkService.requestVoid(for: .delete(url: url))
        }
    }

    // MARK: - Private

    /// Wraps a throwing network call into a `Result`, mapping ``NetworkError`` to ``ServerError``.
    private func perform<T>(_ work: () async throws -> T) async -> Result<T, ServerError> {
        do {
            return .success(try await work())
        } catch let error as ServerError {
            return .failure(error)
        } catch let error as NetworkError {
            return .failure(error.asServerError())
        } catch {
            return .failure(.unexpected)
        }
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
