//  TransactionListItemViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities
import Extensions
import CoreModels

@Observable
final class TransactionItemViewModel: Equatable, Identifiable {

    var transaction: CoreModels.Transaction

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

extension TransactionItemViewModel {
    
    static func == (lhs: TransactionItemViewModel, rhs: TransactionItemViewModel) -> Bool {
        lhs.transaction.id == rhs.transaction.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(transaction.id)
    }
    
    static var placeHolder: [TransactionItemViewModel] {
        return AnyIterator { }
            .prefix(7)
            .map { .init(transaction: CoreModels.Transaction.mock()) }
    }
}
