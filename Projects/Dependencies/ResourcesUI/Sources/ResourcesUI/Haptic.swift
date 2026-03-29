//  Haptic.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import UIKit

public struct Haptic {

    public static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard let style = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: style.rawValue) else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    public static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        guard let type = UINotificationFeedbackGenerator.FeedbackType(rawValue: type.rawValue) else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
