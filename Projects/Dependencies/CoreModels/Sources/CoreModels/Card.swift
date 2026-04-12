//  Card.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

public struct Card: Identifiable, Hashable, Codable {

    public let id: String

    let type: CardType
    let color: ColorCode

    /// Optional hex color override (e.g. `"#A34FD2"`). Overrides `color` when present.
    let hexa: String?

    let holderName: String

    let limit: Int
    let available: Int
    
    let closingDate: Date
    let dueDate: Date
    
}

// MARK: - Mock

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
