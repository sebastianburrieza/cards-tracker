//  Skeleton.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI

public struct RedactAndAnimationViewModifier: ViewModifier {
    private let condition: Bool

    public init(condition: Bool) {
        self.condition = condition
    }

    public func body(content: Content) -> some View {
        if condition {
            content
                .redacted(reason: .placeholder)
        } else {
            content
                .transition(.opacity.animation(.snappy(duration: 0.2)))
        }
    }
}

extension View {
    
    public func isSkeletonView(_ condition: Bool) -> some View {
        return modifier(RedactAndAnimationViewModifier(condition: condition))
    }
}

struct ShimmeringModifier: ViewModifier {
    @State private var isAnimating: Bool = false
    let isActive: Bool
    let duration: Double
    let loop: Bool

    func body(content: Content) -> some View {
        if isActive {
            content.overlay(
                GeometryReader { geometry in
                    if isActive {
                        ShimmeringView(isAnimating: self.$isAnimating, duration: self.duration, loop: self.loop)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .allowsHitTesting(false)
                    }
                }
            )
            .mask(content)
        } else {
            content
        }
    }
}

struct ShimmeringView: View {
    @Binding var isAnimating: Bool
    let duration: Double
    let loop: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        Palette.staticWhite.swiftUI.opacity(0.5),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .offset(x: isAnimating ? 500 : -500)
            .onAppear {
                withAnimation(Animation.timingCurve(0.33, 0.59, 0.81, 0.5, duration: duration).repeatForever(autoreverses: false)) {
                    self.isAnimating = true
                }
            }
            .onDisappear {
                self.isAnimating = false
            }
    }
}

extension View {
    
    public func shimmering(isActive: Bool = true, duration: Double = 2.5, loop: Bool = true) -> some View {
        modifier(ShimmeringModifier(isActive: isActive, duration: duration, loop: loop))
    }
}
