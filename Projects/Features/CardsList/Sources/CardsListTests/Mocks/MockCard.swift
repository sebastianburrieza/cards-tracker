//
//  MockCard.swift
//  CardsList
//
//  Created by Catalina Burrieza on 16/04/2026.
//  Copyright © 2026 CardsTracker. All rights reserved.
//


// MARK: - Card Mock Extension

extension Card {
    static func mock(id: String = UUID().uuidString,
                     type: CardType = .creditPlastic,
                     color: ColorCode = .GREEN,
                     hexa: String? = nil,
                     holderName: String = "Test User",
                     limit: Int = 100000,
                     available: Int = 50000,
                     closingDate: Date = Date(),
                     dueDate: Date = Date()) -> Card {
        Card(id: id,
             type: type,
             color: color,
             hexa: hexa,
             holderName: holderName,
             limit: limit,
             available: available,
             closingDate: closingDate,
             dueDate: dueDate)
    }
}