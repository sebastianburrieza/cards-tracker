//  TransactionListItemViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities
import Extensions
import CoreModels

final class TransactionItemViewModel: ObservableObject {

    let transaction: CoreModels.Transaction

    init(transaction: CoreModels.Transaction) {
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
    
    var categoryColor: Color {
        transaction.category?.color ?? Palette.grayMedium.swiftUI
    }
}
