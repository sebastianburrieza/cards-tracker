//  Skeleton.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

struct TextColor: ViewModifier {
    @Environment(\.redactionReasons) var redactionReasons
    let placeholderColor: Color
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(redactionReasons.contains(.placeholder) ? placeholderColor : color)
    }
}

struct BackgroundColor: ViewModifier {
    @Environment(\.redactionReasons) var redactionReasons
    let placeholderColor: Color
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .background(redactionReasons.contains(.placeholder) ? placeholderColor : color)
    }
}

public struct RedactAndAnimationViewModifier: ViewModifier {
  private let condition: Bool

  init(condition: Bool) {
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
    public func skeletonView(condition: Bool) -> some View {
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
                    gradient: Gradient(
                        colors: [
                            .clear,
                            Palette.staticWhite.swiftUI.opacity(0.5),
                            .clear
                        ]
                    ),
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
    func shimmering(isActive: Bool = true, duration: Double = 2.5, loop: Bool = true) -> some View {
        modifier(ShimmeringModifier(isActive: isActive, duration: duration, loop: loop))
    }
}

public enum TransitionStyle {
    case push
    case pop
    case present
    case dismiss
    case scale
    case rotation
    case none
}

public struct TransitionViewModifier: ViewModifier {
    
    private let style: TransitionStyle
    
    @State private var offset: CGFloat
    @State private var scale: CGFloat
    @State private var rotation: Angle

    init(style: TransitionStyle, offset: CGFloat, scale: CGFloat, rotation: Angle) {
        self.style = style
        self.offset = offset
        self.scale = scale
        self.rotation = rotation
    }
  
    public func body(content: Content) -> some View {
        switch style {
        case .push, .pop:
            content
                .offset(x: offset)
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) {
                        offset = 0
                    }
                }
        case .present, .dismiss:
            content
                .offset(y: offset)
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) {
                        offset = 0
                    }
                }
        case .scale:
            content
                .scaleEffect(scale)
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) {
                        scale = 1
                    }
                }
        case .rotation:
            content
                .rotation3DEffect(rotation, axis: (x: 0, y: 1, z: 0))
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) {
                        rotation = .degrees(0)
                    }
                }
        default:
            content
        }
    }
}

extension View {
    
    public func transitionStyle(_ style: TransitionStyle) -> some View {
        var offset: CGFloat = 0
        var scale: CGFloat = 1
        var rotation: Angle = .zero
        switch style {
        case .push:
            offset = 100
        case .pop:
            offset = -100
        case .present:
            offset = 100
        case .dismiss:
            offset = -100
        case .scale:
            scale = 1.3
        case .rotation:
            rotation = .degrees(180)
        default:
            break
        }
        return modifier(TransitionViewModifier(style: style, offset: offset, scale: scale, rotation: rotation))
    }
    
}

