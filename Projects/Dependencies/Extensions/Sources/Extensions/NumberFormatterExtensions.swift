//  NumberFormatterExtensions.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import SwiftUI
import Utilities
import CoreModels

extension NumberFormatter {

    public enum FormatterOption {
        case minFractionDigits(_ value: Int)
        case maxFractionDigits(_ value: Int)
        case roundingMode(_ mode: NumberFormatter.RoundingMode)
        case showCurrencyISO
        case showCurrencySymbol
        case completeDecimals
    }

    public static func formatNumber(_ value: Int, options: [FormatterOption] = [], locale: Locale = Locale.current) -> String {
        let amount = convertToAmount(value)
        return formatValue(amount, options: options, locale: locale)
    }

    public static func convertToAmount(_ value: Int) -> Double {
        let conversion = String(format: "%.2f", Double(value) / 100.0)
        return (conversion as NSString).doubleValue
    }

    public static var customCurrencyGroupingSeparator: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter.currencyGroupingSeparator
    }

    public static var customCurrencyDecimalSeparator: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter.currencyDecimalSeparator
    }

    public static func formatValue(_ value: Double,
                                   currency: Currency? = nil,
                                   options: [FormatterOption] = [],
                                   locale: Locale = Locale.current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale

        let defaultOptions: [FormatterOption] = [
            .minFractionDigits(2),
            .maxFractionDigits(currency?.decimals ?? 2),
            .roundingMode(.down)
        ]
        var completeDecimals = false

        for option in defaultOptions + options {
            switch option {
            case .minFractionDigits(let minValue):
                if let decimals = currency?.decimals, minValue > decimals { continue }
                formatter.minimumFractionDigits = minValue

            case .maxFractionDigits(let maxValue):
                if let decimals = currency?.decimals, maxValue > decimals { continue }
                formatter.maximumFractionDigits = maxValue

            case .roundingMode(let mode):
                formatter.roundingMode = mode

            case .showCurrencyISO:
                guard let currency = currency else { continue }
                formatter.numberStyle = .currency
                formatter.currencySymbol = "\(currency.ISO)\(nonBreakableSpace)"

            case .showCurrencySymbol:
                guard let currency = currency else { continue }
                let symbol = currency.symbol
                formatter.numberStyle = .currency
                formatter.currencySymbol = symbol.count == 1 ? symbol : "\(symbol)\(nonBreakableSpace)"

            case .completeDecimals:
                completeDecimals = true
            }
        }

        let formattedNumber = formatter.format(from: value)
        if completeDecimals,
           formattedNumber.contains(formatter.currencyDecimalSeparator),
           formatter.minimumFractionDigits != formatter.maximumFractionDigits {
            formatter.minimumFractionDigits = formatter.maximumFractionDigits
            return formatter.format(from: value)
        } else {
            return formattedNumber
        }
    }

    public static func formatValue(_ value: Int,
                                   currency: Currency? = nil,
                                   options: [FormatterOption] = [],
                                   locale: Locale = Locale.current) -> String {
        let amount = convertToAmount(value)
        return formatValue(amount, currency: currency, options: options, locale: locale)
    }

    public static var nonBreakableSpace: String { "\u{202F}" }

    public func format(from value: Double) -> String {
        string(from: value as NSNumber)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[\\s\n]+", with: Self.nonBreakableSpace, options: .regularExpression, range: nil) ?? "-"
    }
}
