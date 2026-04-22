//  Palette.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import UIKit
import SwiftUI

public enum Palette: String, CaseIterable, Codable {

    // Primary
    case primary
    
    // Backgrounds
    case backgroundLight
    case backgroundMedium

    // Neutrals
    case black
    case white
    case blackHeavy
    case whiteHeavy
    
    case grayUltraLight
    case grayLight
    case grayMedium
    case grayDark
    case grayUltraDark

    // Static
    case staticBlack
    case staticWhite

    // Colors
    case green
    case yellow
    case red
    case blue
    case orange
    case violet
    case purple
    case pink
}

extension Palette {

    public var color: UIColor {
        let bundle = Bundle.main
        guard let paletteColor = UIColor(named: rawValue, in: bundle, compatibleWith: nil) else {
            assertionFailure("Couldn´t find color \(self), did you add it to Assets/xcassets?")
            return UIColor()
        }
        return paletteColor
    }

    public var swiftUI: Color {
        guard Palette.allCases.contains(self) else {
            assertionFailure("Couldn´t find color \(self), did you add it to Assets/xcassets?")
            return Color(.clear)
        }
        return Color(self.rawValue, bundle: Bundle.main)
    }
}
