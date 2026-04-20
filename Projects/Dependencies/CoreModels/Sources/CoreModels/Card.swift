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
    public let bankName: String
    public let lastFourDigits: String

    public let limit: Int
    public let available: Int

    public let closingDate: Date
    public let dueDate: Date

    /// Whether the card is currently paused by the user.
    /// Defaults to `false` when absent from the server response.
    public let isPaused: Bool

    public init(id: String,
                type: CardType,
                color: ColorCode,
                hexa: String?,
                holderName: String,
                bankName: String = "",
                lastFourDigits: String = "",
                limit: Int,
                available: Int,
                closingDate: Date,
                dueDate: Date,
                isPaused: Bool = false) {
        self.id = id
        self.type = type
        self.color = color
        self.hexa = hexa
        self.holderName = holderName
        self.bankName = bankName
        self.lastFourDigits = lastFourDigits
        self.limit = limit
        self.available = available
        self.closingDate = closingDate
        self.dueDate = dueDate
        self.isPaused = isPaused
    }

    // MARK: - Mutations

    /// Returns a copy of this card with `isPaused` set to the given value.
    /// Because `Card` is a struct with `let` properties we can't mutate in place —
    /// this is the Swift equivalent of Kotlin's `data class copy(isPaused = ...)`.
    public func copy(isPaused: Bool) -> Card {
        Card(id: id, type: type, color: color, hexa: hexa,
             holderName: holderName, bankName: bankName, lastFourDigits: lastFourDigits,
             limit: limit, available: available,
             closingDate: closingDate, dueDate: dueDate, isPaused: isPaused)
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, type, color, hexa, holderName, bankName, lastFourDigits
        case limit, available, closingDate, dueDate, isPaused
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(CardType.self, forKey: .type)
        color = try container.decode(ColorCode.self, forKey: .color)
        hexa = try container.decodeIfPresent(String.self, forKey: .hexa)
        holderName = try container.decode(String.self, forKey: .holderName)
        bankName = try container.decodeIfPresent(String.self, forKey: .bankName) ?? ""
        lastFourDigits = try container.decodeIfPresent(String.self, forKey: .lastFourDigits) ?? ""
        limit = try container.decode(Int.self, forKey: .limit)
        available = try container.decode(Int.self, forKey: .available)
        closingDate = try container.decode(Date.self, forKey: .closingDate)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        // `isPaused` may be absent from older server responses — default to false
        isPaused = try container.decodeIfPresent(Bool.self, forKey: .isPaused) ?? false
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
