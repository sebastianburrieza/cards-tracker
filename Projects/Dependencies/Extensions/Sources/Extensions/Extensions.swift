//  Extensions.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import Utilities
import SwiftUI

// MARK: - View

extension View {

    @ViewBuilder
    public func isHidden(_ hidden: Bool) -> some View {
        self.opacity(hidden ? 0 : 1)
            .frame(width: hidden ? 0 : nil, height: hidden ? 0 : nil)
    }
}

// MARK: - UIWindow

extension UIWindow {

    public static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window 
            }
        }
        return nil
    }
}
