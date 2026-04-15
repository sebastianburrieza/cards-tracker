//  Card.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

public struct Card: Identifiable, Hashable, Codable {

    public let id: String

    public let type: CardType
    public let color: ColorCode

    /// Optional hex color override (e.g. `"#A34FD2"`). Overrides `color` when present.
    public let hexa: String?

    public let holderName: String

    public let limit: Int
    public let available: Int
    
    public let closingDate: Date
    public let dueDate: Date
}

public enum CardType: String, Codable {
    case debitVirtual
    case debitPlastic
    case creditVirtual
    case creditPlastic
    /// UI-only state — never sent by the server.
    case skeleton
    /// UI-only state — never sent by the server.
    case failure
}

public enum ColorCode: String, Codable {
    case WHITE
    case PINK
    case VIOLET
    case GREEN
    case PURPLE
    case ORANGE
    
    case SKELETON
}

// MARK: - Mock

public extension Card {
    
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
