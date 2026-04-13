//  TransactionDetailViewModel.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import SwiftUI
import Factory
import Extensions
import CoreModels

// MARK: - Navigation delegate

/// Handles navigation events triggered from the transaction detail screen.
protocol TransactionDetailNavigationDelegate: AnyObject {
    func dismiss()
}

// MARK: - ViewModel

@Observable
@MainActor
final class TransactionDetailViewModel {

    // MARK: - Public state

    var merchantName: String = ""
    var formattedAmount: String = ""
    var formattedDate: String = ""
    var categoryName: String?
    var categoryIcon: String?
    var categoryColor: Color = .red

    var isLoading = true
    var errorMessage: String?

    let transactionId: String

    // MARK: - Not observed

    @ObservationIgnored
    weak var delegate: TransactionDetailNavigationDelegate?

    @ObservationIgnored
    @Injected(\.transactionDetailRepository) private var repository

    // MARK: - Init

    init(transactionId: String) {
        self.transactionId = transactionId
    }

    // MARK: - Data loading

    /// Fetches the transaction from the repository and populates formatted display properties.
    func fetchTransaction() async {
        isLoading = true
        errorMessage = nil

        do {
            let transaction = try await repository.fetchTransaction(id: transactionId)
            formatTransaction(transaction)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Actions

    func close() {
        delegate?.dismiss()
    }

    func share() {
        // TODO: Integrate with UIActivityViewController via delegate
    }

    // MARK: - Private

    private func formatTransaction(_ transaction: TransactionDetail) {
        merchantName = transaction.merchantName
        formattedAmount = NumberFormatter.formatValue(
            transaction.amount,
            currency: transaction.currency,
            options: [.showCurrencySymbol]
        )
        formattedDate = DateFormatter.dayMonthYearLongFormatter.string(from: transaction.date)
        categoryName = transaction.categoryName
        categoryIcon = transaction.categoryIcon
        categoryColor = colorForCategory(transaction.categoryName)
    }

    private func colorForCategory(_ name: String?) -> Color {
        guard let name = name?.lowercased() else { return .gray }
        switch name {
        case "delivery":   return .red
        case "restaurant": return .orange
        case "streaming":  return .blue
        case "shopping":   return .purple
        default:           return .gray
        }
    }
}
