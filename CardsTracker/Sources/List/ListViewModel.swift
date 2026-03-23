//  ListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

final class ListViewModel: ObservableObject {
    @Published var cards: [Card] = Card.mocks
}

extension Card {
    static var mocks: [Card] = [
        Card(id: UUID(),
             type: .creditPlastic,
             color: .GREEN,
             hexa: nil,
             holderName: "Sebastian A Burrieza",
             amountUsedCents: 186750000,
             limitCents: 220000000,
             daysUntilDue: 7
        ),
        Card(id: UUID(),
             type: .creditPlastic,
             color: .PURPLE,
             hexa: nil,
             holderName: "Sebastian A Burrieza",
             amountUsedCents: 16750000,
             limitCents: 200000000,
             daysUntilDue: 16
        )
    ]
}
