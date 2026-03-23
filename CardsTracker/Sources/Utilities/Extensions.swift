//  Extensions.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder
    public func isHidden(_ hidden: Bool) -> some View {
            self.opacity(hidden ? 0 : 1)
                .frame(width: hidden ? 0 : nil, height: hidden ? 0 : nil)
    }
}

extension UIWindow {
    public static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}

extension UIScreen {
    public static var current: UIScreen? {
        UIWindow.current?.screen
    }
    
    public static var screenWidth: CGFloat {
        UIScreen.current?.bounds.width ?? 375
    }
    
    public static var screenHeight: CGFloat {
        UIScreen.current?.bounds.height ?? 667
    }
    
    public static var isNarrow: Bool {
        return self.screenWidth <= 375
    }
}

public extension NumberFormatter {
    enum FormatterOption {
        case minFractionDigits(_ value: Int)
        case maxFractionDigits(_ value: Int)
        case roundingMode(_ mode: NumberFormatter.RoundingMode)
        case showCurrencyISO
        case showCurrencySymbol
        case completeDecimals
    }
    
    static func formatAmount(amount: Int, positiveColor: Palette = .green, negativeColor: Palette = .grayDark, decimalAlpha: CGFloat = 0.5, hasSign: Bool = false, currency: CurrencyProtocol? = nil) -> AttributedString {
        
        var attributed = AttributedString()
        
        let valueToBeFormatted: Int
        var amountColor: Color
        let sign: String
        
        valueToBeFormatted = abs(amount)
        if amount > 0 {
            amountColor = positiveColor.swiftUI
        } else if amount < 0 {
            amountColor = negativeColor.swiftUI
        } else {
            amountColor = Palette.grayDark.swiftUI
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
    
    static func formatNumber(_ value: Int, options: [FormatterOption] = [], locale: Locale = Locale.current) -> String {
        let amount = getAmount(fromCent: value)
        return formatValue(amount, options: options, locale: locale)
    }
    
    static func getAmount(fromCent: Int) -> Double {
        let conversion = String(format: "%.2f", Double(fromCent) / 100.0)
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
}

extension NumberFormatter {
    
    static func formatValue(_ value: Double, currency: Currency? = nil, options: [FormatterOption] = [], locale: Locale = Locale.current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        
        let defaultOptions: [FormatterOption] = [.minFractionDigits(2),
                                                 .maxFractionDigits(currency?.decimals ?? 2),
                                                 .roundingMode(.down)]
        var completeDecimals = false
        
        for option in defaultOptions + options {
            switch option {
            case .minFractionDigits(let minValue):
                if let decimals = currency?.decimals, minValue > decimals {
                    continue
                }
                
                formatter.minimumFractionDigits = minValue
                
            case .maxFractionDigits(let maxValue):
                if let decimals = currency?.decimals, maxValue > decimals {
                    continue
                }
                
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

    static var nonBreakableSpace: String {
        return "\u{202F}"
    }
    
    func format(from value: Double) -> String {
        string(from: value as NSNumber)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[\\s\n]+", with: Self.nonBreakableSpace, options: .regularExpression, range: nil) ?? "-"
    }
}

extension String {
    
    func replacingOccurrences(of mapAttributed: [String: AttributedString]) -> AttributedString {
        var attributedString = AttributedString(self)
        for (key, value) in mapAttributed {
            let occurrencesOfKey = attributedString.characters.map { String($0) }.joined(separator: key)
            (0...occurrencesOfKey.count - 1).forEach { _ in
                if let range = attributedString.range(of: key) {
                    attributedString.replaceSubrange(range, with: value)
                }
            }
        }
        return attributedString
    }
}

public enum Currency: String, Codable, CaseIterable, Equatable {
    case ARS
    case USD
    
    public var decimals: Int {
        2
    }
    
    private static var _primary: Currency?
}

public protocol CurrencyProtocol: Codable {
    var ISO: String { get }
    var symbol: String { get }
    var color: Palette { get }
    var pluralDescription: String { get }
}

extension Currency: CurrencyProtocol {
    
    public var identifier: String {
        switch self {
        case .ARS:
            return "es_AR"
        case .USD:
            return "en_US"
        }
    }
    
    public var ISO: String {
        switch self {
        case .ARS:
            return "ARS"
        case .USD:
            return "USD"
        }
    }
    
    public var symbol: String {
        switch self {
        case .ARS:
            return "$"
        case .USD:
            return "USD"
        }
    }
    
    public var color: Palette {
        switch self {
        case .ARS:
            return .primary
        case .USD:
            return .green
        }
    }
    
    public var pluralDescription: String {
        switch self {
        case .ARS:
            return "Pesos"
        case .USD:
            return "Dólares"
        }
    }
}

public extension Color {
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let color = UIColor(self)
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrigthness: CGFloat = 0
        var currentOpacity: CGFloat = 0
        
        if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentOpacity) {
            return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrigthness + brightness, opacity: currentOpacity + opacity)
        }
        return self
    }
    
    func darkenColor(by factor: CGFloat = 0.9) -> Color {
        let ciColor = CIColor(cgColor: UIColor(self).cgColor)
        return Color(red: Double(ciColor.red * factor), green: Double(ciColor.green * factor), blue: Double(ciColor.blue * factor), opacity: Double(ciColor.alpha))
    }
}

extension DateFormatter {
    
    static var shortMonthYearDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "es")
        return dateFormatter
    }
    
    static var dayNumberFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }
}
