//  AnimatedDots.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI

public enum ColorValue {
    case white
    case primary
    case color(Color)
    
    var color: Color {
        switch self {
        case .white:
            Palette.staticWhite.swiftUI
        case .primary:
            Palette.primary.swiftUI
        case .color(let color):
            color
        }
    }
}

public enum SizeValue: CGFloat {
    case small = 5
    case medium = 10
    case large = 15
}

public struct AnimatedDots: View {
    
    var color: Color
    var size: CGFloat
    @State private var isAnimate = false
    
    public init(color: ColorValue = .white, size: SizeValue = .medium) {
        self.color = color.color
        self.size = size.rawValue
    }
    
    public var body: some View {
        
        HStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(isAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever())
            
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(isAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.25))
            
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(isAnimate ? 1.0 : 0.5)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.5))
            
        }
        .onAppear {
            self.isAnimate = true
        }
        .opacity(isAnimate ? 1 : 0)
        .frame(maxWidth: .infinity, maxHeight: 20, alignment: .center)
    }
    
}
