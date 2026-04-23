//  TransactionListItemViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities
import Extensions
import CoreModels

@Observable
final class TransactionItemViewModel: Equatable, Identifiable, Hashable {

    var transaction: CoreModels.Transaction

    init(transaction: CoreModels.Transaction) {
        self.transaction = transaction
    }
    
    var colorAmount: Color {
        transaction.currency == .ARS ? Palette.grayUltraDark.swiftUI : Palette.green.swiftUI
    }

    var formattedAmount: String {
        let currency = transaction.currency
        return NumberFormatter.formatValue(transaction.amount, currency: currency, options: [.showCurrencySymbol])
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
        // Each placeholder needs a unique id so LazyVStack doesn't collide on the ForEach key.
        // Transaction.mock() always returns the same hardcoded UUID, so we override it per index.
        return (0..<7).map { index in
            .init(transaction: CoreModels.Transaction.mock(id: "placeholder-\(index)"))
        }
    }
}
