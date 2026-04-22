//  Fonts.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI

/// Design-system font helpers that always return SF Pro Rounded.
///
/// Uses the system `.rounded` font design trait — no bundled font files required.
/// This is the Apple-recommended approach for accessing SF Pro Rounded on iOS 17+.
public final class Fonts {

    // MARK: UIKit

    public static func heavy(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .heavy).rounded
    }

    public static func bold(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .bold).rounded
    }
    
    public static func semibold(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .semibold).rounded
    }

    public static func medium(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .medium).rounded
    }

    public static func regular(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .regular).rounded
    }

    public static func thin(size: CGFloat) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: .thin).rounded
    }

    // MARK: SwiftUI

    public static func heavy(size: CGFloat) -> Font {
        Font(Fonts.heavy(size: size) as CTFont)
    }

    public static func bold(size: CGFloat) -> Font {
        Font(Fonts.bold(size: size) as CTFont)
    }
    
    public static func semibold(size: CGFloat) -> Font {
        Font(Fonts.semibold(size: size) as CTFont)
    }

    public static func medium(size: CGFloat) -> Font {
        Font(Fonts.medium(size: size) as CTFont)
    }

    public static func regular(size: CGFloat) -> Font {
        Font(Fonts.regular(size: size) as CTFont)
    }

    public static func thin(size: CGFloat) -> Font {
        Font(Fonts.thin(size: size) as CTFont)
    }
}

// MARK: - UIFont + Rounded

private extension UIFont {

    /// Returns this font with the `.rounded` design trait applied.
    /// Falls back to self if the descriptor transformation fails.
    var rounded: UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

// MARK: - Legacy support

public enum FontType {
    case regular
    case medium
    case semibold
    case bold
}
