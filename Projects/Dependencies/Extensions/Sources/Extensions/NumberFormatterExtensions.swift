//  NumberFormatterExtensions.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import SwiftUI
import ResourcesUI
import Utilities
import CoreModels

public extension NumberFormatter {

    enum FormatterOption {
        case minFractionDigits(_ value: Int)
        case maxFractionDigits(_ value: Int)
        case roundingMode(_ mode: NumberFormatter.RoundingMode)
        case showCurrencyISO
        case showCurrencySymbol
        case completeDecimals
    }

    static func formatNumber(_ value: Int, options: [FormatterOption] = [], locale: Locale = Locale.current) -> String {
        let amount = convertToAmount(value)
        return formatValue(amount, options: options, locale: locale)
    }

    static func convertToAmount(_ value: Int) -> Double {
        let conversion = String(format: "%.2f", Double(value) / 100.0)
        return (conversion as NSString).doubleValue
    }

    static var customCurrencyGroupingSeparator: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter.currencyGroupingSeparator
    }

    static var customCurrencyDecimalSeparator: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        return formatter.currencyDecimalSeparator
    }

    static func formatValue(_ value: Double,
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

    static func formatValue(_ value: Int,
                            currency: Currency? = nil,
                            options: [FormatterOption] = [],
                            locale: Locale = Locale.current) -> String {
        let amount = convertToAmount(value)
        return formatValue(amount, currency: currency, options: options, locale: locale)
    }

    static var nonBreakableSpace: String { "\u{202F}" }

    func format(from value: Double) -> String {
        string(from: value as NSNumber)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[\\s\n]+", with: Self.nonBreakableSpace, options: .regularExpression, range: nil) ?? "-"
    }
    
    static func formatAmount(_ amount: Int,
                             positiveColor: Color = Palette.green.swiftUI,
                             negativeColor: Color = Palette.black.swiftUI,
                             decimalAlpha: CGFloat = 0.5,
                             hasSign: Bool = false,
                             currency: Currency? = nil) -> AttributedString {
        
        var attributed = AttributedString()
        
        let valueToBeFormatted: Int
        var amountColor: Color
        let sign: String
        
        valueToBeFormatted = abs(amount)
        if case .USD = currency {
            amountColor = Palette.green.swiftUI
        } else if amount > 0 {
            amountColor = positiveColor
        } else if amount < 0 {
            amountColor = negativeColor
        } else {
            amountColor = Palette.black.swiftUI
        }
        
        sign = amount > 0 ? "+" : "-"
        
        let valueString = NumberFormatter.formatNumber(valueToBeFormatted, options: [.minFractionDigits(2)])
        let valueSeparator = valueString.components(separatedBy: NumberFormatter.customCurrencyDecimalSeparator)
        
        var signValueAttributed = AttributedString(hasSign ? sign : "")
        signValueAttributed.foregroundColor = amountColor
        
        var currencyValueAttributed = AttributedString(currency?.symbol ?? "")
        currencyValueAttributed.foregroundColor = amountColor.opacity(decimalAlpha)
        
        var amountValueAttributed = AttributedString(valueSeparator[0])
        amountValueAttributed.foregroundColor = amountColor
        
        let decimal = valueSeparator.count == 1 ? "" : NumberFormatter.customCurrencyDecimalSeparator + valueSeparator[1]
        var decimalValueAttributed = AttributedString(decimal)
        decimalValueAttributed.foregroundColor = amountColor.opacity(decimalAlpha)
        
        if currency != nil && !hasSign {
            let currencyAttributed = "{CURRENCY} {AMOUNT}{CENTS}"
                .replacingOccurrences(of: [
                    "{CURRENCY}": currencyValueAttributed,
                    "{AMOUNT}": amountValueAttributed,
                    "{CENTS}": decimalValueAttributed])
            attributed.append(currencyAttributed)
        } else if valueToBeFormatted == 0 {
            let amountAttributed = "{AMOUNT}{CENTS}"
                .replacingOccurrences(of: [
                    "{AMOUNT}": amountValueAttributed,
                    "{CENTS}": decimalValueAttributed])
            attributed.append(amountAttributed)
        } else {
            let signAttributed = "{SIGN} {AMOUNT}{CENTS}"
                .replacingOccurrences(of: [
                    "{SIGN}": signValueAttributed,
                    "{AMOUNT}": amountValueAttributed,
                    "{CENTS}": decimalValueAttributed])
            attributed.append(signAttributed)
        }
        return attributed
    }
}
