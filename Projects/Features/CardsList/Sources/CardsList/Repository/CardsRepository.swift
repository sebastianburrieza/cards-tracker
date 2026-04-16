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

    func fetchCard(id: String) async -> Result<Card, ServerError> {
        guard let url = Endpoint.cards else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform {
            let all = try await networkService.request([Card].self, for: URLRequest(url: url))
            guard let card = all.first(where: { $0.id == id }) else {
                throw ServerError(.cardNotFound)
            }
            return card
        }
    }

    func fetchTransactions(cursor: String, cardId: String?, pageSize: Int) async -> Result<TransactionsPage, ServerError> {
        guard let url = Endpoint.transactions else {
            return .failure(ServerError(.invalidURL))
        }
        return await perform {
            let all = try await networkService.request([Transaction].self, for: URLRequest(url: url))
            let filtered = cardId.map { id in all.filter { $0.cardId == id } } ?? all
            let offset = Int(cursor) ?? 0
            let slice = Array(filtered.dropFirst(offset).prefix(pageSize))
            let nextOffset = offset + slice.count
            let nextCursor: String? = nextOffset < filtered.count ? String(nextOffset) : nil
            return TransactionsPage(
                cursor: nextCursor,
                results: slice,
                totalAmount: filtered.reduce(0) { $0 + $1.amount },
                totalTransactions: filtered.count
            )
        }
    }

    // MARK: - Write
    //
    // No real backend is available yet, so write operations return simulated success
    // without hitting the network. The read operations (fetchCards, fetchTransactions)
    // still exercise the full HTTP + decoding stack via GitHub raw JSON.
    //
    // To wire a real API: replace each `return .success(...)` with a `perform { ... }`
    // block pointing at the real endpoint — no feature-layer code needs to change.

    func createCard(_ card: Card) async -> Result<Card, ServerError> {
        return .success(card)
    }

    func updateCard(_ card: Card) async -> Result<Card, ServerError> {
        return .success(card)
    }

    func deleteCard(id: String) async -> Result<Void, ServerError> {
        return .success(())
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
