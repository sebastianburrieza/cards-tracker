//  ColorExtensions.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

extension Color {

    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    public func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let color = UIColor(self)
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrigthness: CGFloat = 0
        var currentOpacity: CGFloat = 0

        if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentOpacity) {
            return Color(hue: currentHue + hue,
                         saturation: currentSaturation + saturation,
                         brightness: currentBrigthness + brightness,
                         opacity: currentOpacity + opacity)
        }
        return self
    }

    public func darkenColor(by factor: CGFloat = 0.9) -> Color {
        let ciColor = CIColor(cgColor: UIColor(self).cgColor)
        return Color(red: Double(ciColor.red * factor),
                     green: Double(ciColor.green * factor),
                     blue: Double(ciColor.blue * factor),
                     opacity: Double(ciColor.alpha))
    }
}
