//  Card.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

struct Card: Identifiable {
    let id: UUID
    let type: CardType
    let color: ColorCode
    let hexa: String?
    let holderName: String
    let amountUsedCents: Int
    let limitCents: Int
    let daysUntilDue: Int

}
