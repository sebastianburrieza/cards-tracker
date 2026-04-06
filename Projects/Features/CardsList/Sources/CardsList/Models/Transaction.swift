//  Transaction.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import SwiftUI
import ResourcesUI
import CoreModels

struct Transaction: Identifiable, Hashable, Codable {
    let id: String
    let merchantName: String
    let date: Date
    let amount: Int
    let currency: Currency
    let installment: Int?
    let totalInstallments: Int?
    let totalInstallmentsAmount: Int?
    
    /// The identifier of the card uses for the transaction
    let cardId: String

    /// Optional store metadata. Not always present in the API response.
    let store: Store?

    let category: TransactionCategory?
    
    init(id: String,
         merchantName: String,
         date: Date,
         amount: Int,
         currency: String,
         installment: Int? = nil,
         totalInstallments: Int? = nil,
         totalInstallmentsAmount: Int? = nil,
         cardId: String,
         store: Store? = nil,
         category: TransactionCategory? = nil) {
        self.id = id
        self.merchantName = merchantName
        self.date = date
        self.amount = amount
        self.currency = Currency(rawValue: currency) ?? .ARS
        self.installment = installment
        self.totalInstallments = totalInstallments
        self.totalInstallmentsAmount = totalInstallmentsAmount
        self.cardId = cardId
        self.store = store
        self.category = category
    }
}

// MARK: - TransactionCategory

enum TransactionCategory: String, Hashable, Codable {
    case restaurant
    case delivery
    case streaming
    case shopping
    case other

    var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .delivery:   return "scooter"
        case .streaming:  return "film"
        case .shopping:   return "bag"
        case .other:      return "creditcard"
        }
    }
    
    var color: Color {
        switch self {
        case .restaurant: return Palette.blue.swiftUI
        case .delivery:   return Palette.red.swiftUI
        case .streaming:  return Palette.yellow.swiftUI
        case .shopping:   return Palette.violet.swiftUI
        case .other:      return Palette.orange.swiftUI
        }
    }
}

// MARK: - Store

struct Store: Hashable, Codable {
    let name: String
    let logo: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Mock

extension Transaction {
    
    static func mock(id: String = "660e8400-e29b-41d4-a716-446655440011",
                     merchantName: String = "Pedidos Ya",
                     date: Date = Date(timeIntervalSince1970: 1772409600),
                     amount: Int = 3723000,
                     currency: String = "ARS",
                     installment: Int? = nil,
                     totalInstallments: Int? = nil,
                     totalInstallmentsAmount: Int? = nil,
                     cardId: String = "550e8400-e29b-41d4-a716-446655440001",
                     category: TransactionCategory? = TransactionCategory(rawValue: "delivery")) -> Transaction {
        .init(id: id,
              merchantName: merchantName,
              date: date,
              amount: amount,
              currency: currency,
              installment: installment,
              totalInstallments: totalInstallments,
              totalInstallmentsAmount: totalInstallmentsAmount,
              cardId: cardId,
              category: category)
    }
}
