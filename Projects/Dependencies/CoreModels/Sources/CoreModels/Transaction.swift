//  Transaction.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import SwiftUI
import ResourcesUI

public struct Transaction: Identifiable, Hashable, Codable {
    public let id: String
    public let merchantName: String
    public let date: Date
    public let amount: Int
    public let currency: Currency
    public let installment: Int?
    public let totalInstallments: Int?
    public let totalInstallmentsAmount: Int?
    
    /// The identifier of the card uses for the transaction
    public let cardId: String

    /// Optional store metadata. Not always present in the API response.
    public let store: Store?

    public let category: TransactionCategory?
    
    public init(id: String,
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

public enum TransactionCategory: String, Hashable, Codable {
    case restaurant
    case delivery
    case streaming
    case shopping
    case other

    public var icon: String {
        switch self {
        case .restaurant: return "fork.knife"
        case .delivery:   return "scooter"
        case .streaming:  return "film"
        case .shopping:   return "bag"
        case .other:      return "creditcard"
        }
    }
    
    public var color: Color {
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

public struct Store: Hashable, Codable {
    public let name: String
    let logo: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Mock

public extension Transaction {
    
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
