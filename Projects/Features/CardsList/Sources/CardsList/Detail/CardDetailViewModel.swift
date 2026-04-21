//  CardDetailViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Extensions
import CoreModels

enum TransactionFilter: CaseIterable {
    case all, installments, dollars

    var label: String {
        switch self {
        case .all: return "DETAIL_FILTER_ALL".localized
        case .installments: return "DETAIL_FILTER_INSTALLMENTS".localized
        case .dollars: return "DETAIL_FILTER_DOLLARS".localized
        }
    }
}

/// Handles navigation events triggered from the card detail screen.
protocol CardDetailNavigationDelegate: AnyObject {
    func navigateToPrevious()
    func navigateToTransactionDetail(id: String)
    func navigateToSettings()
}

@Observable
final class CardDetailViewModel {

    let card: Card

    var transactions: [CoreModels.Transaction] = []
    var isLoading: Bool = true
    var isFetching: Bool = false

    var selectedFilter: TransactionFilter = .all

    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    // MARK: - Not observed

    @ObservationIgnored
    weak var delegate: CardDetailNavigationDelegate?

    // MARK: - Init

    init(card: Card) {
        self.card = card
    }

    // MARK: - Navigation

    func navigateToSettings() {
        delegate?.navigateToSettings()
    }

    // MARK: - Data loading

    func fetchTransactions() async {
        await MainActor.run {
            isFetching = true
        }
    }

    // MARK: - Formatted values

    var formattedAmountUsed: String {
        let used = card.limit - card.available
        return NumberFormatter.formatValue(used, currency: .ARS, options: [.showCurrencySymbol])
    }

    var formattedAvailable: String {
        NumberFormatter.formatValue(
            card.available,
            currency: .ARS,
            options: [.showCurrencySymbol, .maxFractionDigits(0)]
        )
    }

    var formattedRemaining: String {
        "DETAIL_AVAILABLE".localized(formattedAvailable)
    }
    
    var formattedLastFourDigits: String {
        card.lastFourDigits.isEmpty ? "" : "  •••• \(card.lastFourDigits)"
    }

    var typeLabel: String {
        switch card.type {
        case .creditPlastic, .creditVirtual: return "CREDIT".localized
        case .debitPlastic, .debitVirtual: return "DEBIT".localized
        case .skeleton, .failure: return ""
        }
    }
}
