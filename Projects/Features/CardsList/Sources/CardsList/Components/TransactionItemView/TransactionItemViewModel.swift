//  TransactionListItemViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Utilities
import Extensions

final class TransactionItemViewModel: ObservableObject {

    let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
    }

    var formattedAmount: String {
        NumberFormatter.formatValue(transaction.amount, currency: .ARS, options: [.showCurrencySymbol])
    }

    var formattedDate: String {
        DateFormatter.dayMonthYearLongFormatter.string(from: transaction.date)
    }

    var categoryIcon: String {
        transaction.category?.icon ?? "questionmark"
    }
}
