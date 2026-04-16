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
    
    public init(id: String, type: CardType, color: ColorCode, hexa: String?, holderName: String, limit: Int, available: Int, closingDate: Date, dueDate: Date) {
        self.id = id
        self.type = type
        self.color = color
        self.hexa = hexa
        self.holderName = holderName
        self.limit = limit
        self.available = available
        self.closingDate = closingDate
        self.dueDate = dueDate
    }
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
