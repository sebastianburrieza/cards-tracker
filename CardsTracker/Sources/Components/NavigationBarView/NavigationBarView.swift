//  NavigationBarView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

struct NavigationBarView: View {
    let leftView: AnyView?
    let middleView: AnyView?
    let rightView: AnyView?
    
    private let navigationBarHeight: CGFloat = 40
    
    init(leftView: AnyView? = nil, middleView: AnyView? = nil, rightView: AnyView? = nil) {
        self.leftView = leftView
        self.middleView = middleView
        self.rightView = rightView
    }
    
    var body: some View {
        HStack(alignment: .center) {
            leftView
                .frame(width: 18, height: 18, alignment: .center)
            
            Spacer()
            
            if let midView = middleView { midView }
            
            Spacer()
            
            Group {
                if let rView = rightView { rView } else {
                    Color.clear.frame(width: 18, height: 18, alignment: .center)
                }
            }
        }
        .frame(height: navigationBarHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

enum LeftButtonType {
    case close, back
}

struct LeftButtonView: View {
    let action: () -> Void
    let buttonType: LeftButtonType
    
    var body: some View {
        if buttonType == .close {
            CloseButtonView(tapped: action)
        } else {
            BackButtonView(tapped: action)
        }
    }
}

extension NavigationBarView {
    
    init(leftView: (any View)? = nil, middleView: (any View)? = nil, rightView: (any View)? = nil) {
        self.init(
            leftView: leftView.map { AnyView($0) },
            middleView: middleView.map { AnyView($0) },
            rightView: rightView.map { AnyView($0) }
        )
    }
}

struct CloseButtonView: View {
    let tapped: () -> Void
    var body: some View {
        Button(
            action: {
                Haptic.selection()
                tapped()
            },
            label: {
                ZStack {
                    Circle()
                        .fill(Material.regular)
                        .padding(.all, -8)
                    
                    Image(systemName: "multiply")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Palette.grayDark.swiftUI)
                        .frame(width: 16, height: 16)
                }
            }
        )
        .accessibilityLabel("Cerrar")
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BackButtonView: View {
    let tapped: () -> Void
    var body: some View {
        Button(
            action: {
                Haptic.selection()
                tapped()
            },
            label: {
                ZStack {
                    Circle()
                        .fill(Material.regular)
                        .padding(.all, -8)
                    
                Image(systemName: "chevron.left")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Palette.grayDark.swiftUI)
                    .frame(width: 12, height: 20)
                }
            }
        )
        .accessibilityLabel("Atrás")
        .frame(maxWidth: 40, alignment: .leading)
    }
}
