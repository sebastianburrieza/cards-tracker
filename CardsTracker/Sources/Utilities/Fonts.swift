//  Fonts.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI

final class Fonts {
    
    // MARK: UIKit Fonts
    static func heavy(size: CGFloat) -> UIFont {
        return UIFont.createFont(name: .SFProHeavy, size: size)
    }
    
    static func bold(size: CGFloat) -> UIFont {
        return UIFont.createFont(name: .SFProBold, size: size)
    }
    
    static func medium(size: CGFloat) -> UIFont {
        return UIFont.createFont(name: .SFProMedium, size: size)
    }
    
    static func regular(size: CGFloat) -> UIFont {
        return UIFont.createFont(name: .SFProRegular, size: size)
    }
    
    static func thin(size: CGFloat) -> UIFont {
        return UIFont.createFont(name: .SFProThin, size: size)
    }
    
    
    // MARK: SwiftUI Fonts
    static func heavy(size: CGFloat) -> Font {
        return Font(Fonts.heavy(size: size))
    }
    
    static func bold(size: CGFloat) -> Font {
        return Font(Fonts.bold(size: size))
    }
    
    static func medium(size: CGFloat) -> Font {
        return Font(Fonts.medium(size: size))
    }
    
    static func regular(size: CGFloat) -> Font {
        return Font(Fonts.regular(size: size))
    }
    
    static func thin(size: CGFloat) -> Font {
        return Font(Fonts.thin(size: size))
    }

}

enum FontType {
    case regular
    case medium
    case semibold
    case bold
}

enum FontName: String, CaseIterable {
    case SFProHeavy = "SF-Pro-Rounded-Heavy.otf"
    case SFProBold = "SF-Pro-Rounded-Bold.otf"
    case SFProMedium = "SF-Pro-Rounded-Medium.otf"
    case SFProRegular = "SF-Pro-Rounded-Regular.otf"
    case SFProThin = "SF-Pro-Rounded-Thin.otf"
    
    var noExtension: String {
        var components = self.rawValue.components(separatedBy: ".")
        guard components.count > 1 else {
            return self.rawValue
        }
        components.removeLast(1)
        return components.joined(separator: ".")
    }
    
    var weight: UIFont.Weight {
        switch self {
        case .SFProHeavy:
            return .heavy
        case .SFProBold:
            return .bold
        case .SFProMedium:
            return .medium
        case .SFProRegular:
            return .regular
        case .SFProThin:
            return .thin
        }
    }
}

extension UIFont {
    
    class func createFont(name: FontName, size fontSize: CGFloat) -> UIFont {
        var font: UIFont?
        
        switch name {
        case .SFProHeavy, .SFProBold, .SFProMedium, .SFProRegular, .SFProThin:
            font = UIFont(name: name.noExtension, size: fontSize)
        }
        
        return font ?? UIFont.systemFont(ofSize: fontSize, weight: name.weight)
    }
}
