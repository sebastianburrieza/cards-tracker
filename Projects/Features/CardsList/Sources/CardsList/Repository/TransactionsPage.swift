//  TransactionsPage.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import CoreModels

struct TransactionsPage: Decodable, Equatable {
    var cursor: String?
    var results: [CoreModels.Transaction]
    var totalAmount: Int
    var totalTransactions: Int
}
