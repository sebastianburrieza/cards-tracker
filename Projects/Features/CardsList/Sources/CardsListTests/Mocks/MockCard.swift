//  MockCard.swift
//  Created by Catalina Burrieza on 16/04/2026.

import Foundation
import CoreModels

// MARK: - Card Mock Extension

extension Card {
    
    static func mock(id: String = "550e8400-e29b-41d4-a716-446655440000",
                     type: CardType = .creditPlastic,
                     color: ColorCode = .GREEN,
                     hexa: String? = nil,
                     holderName: String = "Sebastian A Burrieza",
                     limit: Int = 220000000,
                     available: Int = 33250000,
                     closingDate: Date = Date(timeIntervalSince1970: 1293044800),
                     dueDate: Date = Date(timeIntervalSince1970: 1293044800)) -> Card {
        .init(id: id,
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
