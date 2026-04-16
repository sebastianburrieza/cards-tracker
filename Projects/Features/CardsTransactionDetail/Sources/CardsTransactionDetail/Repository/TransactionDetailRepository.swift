//  TransactionDetailRepository.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import Foundation
import CoreModels
import CoreServices

/// Data access interface for the CardsTransactionDetail feature.
///
/// Conform to this protocol to replace the live implementation with a mock:
/// ```swift
/// Container.shared.transactionDetailRepository.register { MockTransactionDetailRepository() }
/// ```
protocol TransactionDetailRepositoryProtocol {

    /// Fetches a single transaction by its identifier.
    /// - Parameter id: The transaction UUID string.
    /// - Throws: ``TransactionDetailError/notFound`` when no match exists, or a network/decoding error.
    func fetchTransaction(id: String) async throws -> TransactionDetail
}

// MARK: - Errors

enum TransactionDetailError: Error, LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound: return "Transaction not found."
        }
    }
}

// MARK: - TransactionDetail model

/// Lightweight model that holds everything the detail screen needs.
struct TransactionDetail: Identifiable, Hashable {
    let id: String
    let merchantName: String
    let date: Date
    let amount: Int
    let currency: Currency
    let installment: Int?
    let totalInstallments: Int?
    let categoryName: String?
    let categoryIcon: String?
}

// MARK: - Live implementation

/// Production ``TransactionDetailRepositoryProtocol`` backed by ``NetworkServiceProtocol``.
///
/// Fetches the full transactions list from the GitHub raw JSON mock and filters by `id`.
/// Swap the endpoint for a real `/transactions/{id}` URL when available.
final class TransactionDetailRepository: TransactionDetailRepositoryProtocol {

    private static let transactionsURL = URL(
        string: "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main/MockData/transactions.json"
    )

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchTransaction(id: String) async throws -> TransactionDetail {
        guard let url = Self.transactionsURL else {
            throw URLError(.badURL)
        }

        let all = try await networkService.request([Transaction].self, for: URLRequest(url: url))

        guard let transaction = all.first(where: { $0.id == id }) else {
            throw TransactionDetailError.notFound
        }

        return TransactionDetail(
            id: transaction.id,
            merchantName: transaction.merchantName,
            date: transaction.date,
            amount: transaction.amount,
            currency: transaction.currency,
            installment: transaction.installment,
            totalInstallments: transaction.totalInstallments,
            categoryName: transaction.category?.rawValue,
            categoryIcon: transaction.category?.icon
        )
    }
}
