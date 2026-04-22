//  ShakeEffect.swift
//  Created by Catalina Burrieza on 22/04/2026.

import SwiftUI

public struct ShakeEffect: GeometryEffect {
    public var amount: CGFloat = 8
    public var shakesPerUnit: CGFloat = 3
    public var animatableData: CGFloat

    public init(attempts: Int, amount: CGFloat = 8, shakesPerUnit: CGFloat = 3) {
        self.animatableData = CGFloat(attempts)
        self.amount = amount
        self.shakesPerUnit = shakesPerUnit
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

public extension View {
    func shake(attempts: Int) -> some View {
        modifier(ShakeEffect(attempts: attempts))
            .animation(.easeOut(duration: 0.4), value: attempts)
    }
}
