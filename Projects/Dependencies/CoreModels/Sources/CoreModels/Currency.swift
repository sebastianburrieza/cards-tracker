//  Currency.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Utilities
import ResourcesUI

public enum Currency: String, Codable, CaseIterable, Equatable {
    case ARS
    case USD

    public var decimals: Int { 2 }
}

/// Defines the display and formatting requirements for a currency type.
public protocol CurrencyProtocol: Codable {
    /// ISO 4217 currency code (e.g. "ARS", "USD").
    var ISO: String { get }
    /// Symbol used for display (e.g. "$", "USD").
    var symbol: String { get }
    /// Associated color from the design palette.
    var color: Palette { get }
    /// Plural name of the currency (e.g. "Pesos", "Dólares").
    var pluralDescription: String { get }
}

extension Currency: CurrencyProtocol {

    public var identifier: String {
        switch self {
        case .ARS: return "es_AR"
        case .USD: return "en_US"
        }
    }

    public var ISO: String {
        switch self {
        case .ARS: return "ARS"
        case .USD: return "USD"
        }
    }

    public var symbol: String {
        switch self {
        case .ARS: return "$"
        case .USD: return "USD"
        }
    }

    public var color: Palette {
        switch self {
        case .ARS: return .primary
        case .USD: return .green
        }
    }

    public var pluralDescription: String {
        switch self {
        case .ARS: return "Pesos"
        case .USD: return "Dólares"
        }
    }
}
