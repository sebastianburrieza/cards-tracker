//  TransitionStyle.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

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

    public init(style: TransitionStyle, offset: CGFloat, scale: CGFloat, rotation: Angle) {
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
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) { offset = 0 }
                }
        case .present, .dismiss:
            content
                .offset(y: offset)
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) { offset = 0 }
                }
        case .scale:
            content
                .scaleEffect(scale)
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) { scale = 1 }
                }
        case .rotation:
            content
                .rotation3DEffect(rotation, axis: (x: 0, y: 1, z: 0))
                .task {
                    withAnimation(.timingCurve(0.10, 0.75, 0.20, 0.90, duration: 0.3)) { rotation = .degrees(0) }
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
        case .push:    offset = 100
        case .pop:     offset = -100
        case .present: offset = 100
        case .dismiss: offset = -100
        case .scale:   scale = 1.3
        case .rotation: rotation = .degrees(180)
        default: break
        }
        return modifier(TransitionViewModifier(style: style, offset: offset, scale: scale, rotation: rotation))
    }
}
