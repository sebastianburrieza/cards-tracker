//  TransactionDetailRepository.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import Foundation
import CoreModels

/// Data access interface for the CardsTransactionDetail feature.
///
/// Conform to this protocol to replace the live implementation with a mock:
/// ```swift
/// Container.shared.transactionDetailRepository.register { MockTransactionDetailRepository() }
/// ```
protocol TransactionDetailRepositoryProtocol {

    /// Fetches a single transaction by its identifier.
    /// - Parameter id: The transaction UUID string.
    /// - Throws: On HTTP or decoding failures.
    func fetchTransaction(id: String) async throws -> TransactionDetail
}

// MARK: - TransactionDetail model

/// Lightweight model that holds everything the detail screen needs.
/// Decoupled from the CardsList `Transaction` type until the models are
/// migrated to CoreModels.
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

// MARK: - Mock implementation

/// Returns hardcoded data so we can develop the UI without a backend.
/// Swap for a real implementation backed by ``NetworkServiceProtocol`` later.
final class MockTransactionDetailRepository: TransactionDetailRepositoryProtocol {

    func fetchTransaction(id: String) async throws -> TransactionDetail {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)

        return TransactionDetail(
            id: id,
            merchantName: "Pedidos Ya",
            date: Date(timeIntervalSince1970: 1_772_409_600), // 2 de marzo 2026
            amount: 3_723_000,
            currency: .ARS,
            installment: nil,
            totalInstallments: nil,
            categoryName: "Delivery",
            categoryIcon: "scooter"
        )
    }
}
