//  CardsRepository.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import Factory
import CoreModels
import CoreServices

/// Live ``CardsRepositoryProtocol`` implementation backed by ``NetworkServiceProtocol``.
///
/// Both endpoints point to GitHub raw JSON files — a zero-infrastructure mock backend
/// that still exercises the full HTTP + decoding stack.
///
/// Swap the URLs for a real API without touching any feature-layer code.
final class CardsRepository: CardsRepositoryProtocol {

    private enum RequestPath: String {
        case cards = "MockData/cards.json"
        case transactions = "MockData/transactions.json"

        var baseUrl: String {
            "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main"
        }

        var url: URL? {
            guard let url = URL(string: "\(baseUrl)/\(rawValue)") else { return nil }
            return url
        }
    }

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - CardsRepositoryProtocol

    func fetchCards() async -> Result<[Card], ServerError> {
        guard let url = RequestPath.cards.url else {
            return .failure(ServerError(.invalidURL))
        }
        let request = URLRequest(url: url)
        do {
            let cards = try await networkService.request([Card].self, for: request)
            return .success(cards)
        } catch let error as ServerError {
            return .failure(error)
        } catch let error as NetworkError {
            return .failure(error.asServerError())
        } catch {
            return .failure(.unexpected)
        }
    }

    func fetchTransactions(for cardId: String) async -> Result<[Transaction], ServerError> {
        guard let url = RequestPath.transactions.url else {
            return .failure(ServerError(.invalidURL))
        }
        let request = URLRequest(url: url)
        do {
            let all = try await networkService.request([Transaction].self, for: request)
            return .success(all.filter { $0.cardId == cardId })
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
