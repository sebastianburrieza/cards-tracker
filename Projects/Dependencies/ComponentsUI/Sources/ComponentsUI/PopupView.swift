//  CustomPopupView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI

struct PopupView: View {
    let icon: Image?
    let content: AnyView?
    let text: String
    let duration: CGFloat
    
    @State private var opacity: CGFloat = 0
    @State private var backgroundOpacity: CGFloat = 0
    @State private var offsetY: CGFloat = 30
    @Binding var isPresented: Bool
    
    var completion: (() -> Void)?

    var body: some View {
        popupView
            .offset(y: offsetY)
            .opacity(opacity)
            .onChange(of: isPresented) { _, isPresented in
                if isPresented {
                    animate(isShown: true)
                    Task { @MainActor in
                        try? await Task.sleep(seconds: duration)
                        animate(isShown: false) {
                            completion?()
                        }
                    }
                } else {
                    animate(isShown: false) {
                        completion?()
                    }
                }
            }
            .transition(.opacity)
            .frame(maxWidth: 250, maxHeight: 250, alignment: .center)
    }

    private var popupView: some View {
        VStack(spacing: 10) {
            iconView
                .accessibilityHidden(true)
                .padding(.top)
                .padding(.horizontal, 8)
            titleView
                .padding(.horizontal)
                .padding(.bottom)
        }.accessibilityElement(children: .combine)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .frame(alignment: .center)
                    .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
    }

    @ViewBuilder
    private var titleView: some View {
        if !text.isEmpty {
            Text(text)
                .font(Fonts.bold(size: 20))
                .foregroundColor(Palette.white.swiftUI)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        if let icon {
            icon
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Palette.white.swiftUI)
                .frame(width: 50, height: 50)
        } else if let content {
            content
        } else {
            Color.clear
        }
    }

    private func animate(isShown: Bool, completion: (() -> Void)? = nil) {
        switch isShown {
        case true:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0).delay(0.3)) {
                opacity = 1
                backgroundOpacity = 1
                offsetY = 0
            }
            Task { @MainActor in
                try? await Task.sleep(seconds: 0.3)
                completion?()
            }
    
        case false:
            withAnimation(.easeOut(duration: 0.2)) {
                backgroundOpacity = 0
                opacity = 0
                offsetY = 30
            }
    
            Task { @MainActor in
                try? await Task.sleep(seconds: 0.2)
                completion?()
            }
        }
    }
}

struct PopupModifier: ViewModifier {
    @Binding private var isPresented: Bool
    private var completion: (() -> Void)?
    
    private let icon: Image?
    private let content: AnyView?
    private let text: String
    private let duration: CGFloat
    
    init(icon: Image? = nil,
         content: AnyView? = nil,
         text: String = "",
         duration: CGFloat = 2,
         isPresented: Binding<Bool>,
         completion: (() -> Void)?) {
        self.icon = icon
        self.content = content
        self.text = text
        self.duration = duration
        self.completion = completion
        _isPresented = isPresented
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            PopupView(icon: icon,
                      content: self.content,
                      text: text,
                      duration: duration,
                      isPresented: $isPresented,
                      completion: completion)
        }
    }
}

public extension View {
    
    func popup<Content: View>(@ViewBuilder view: @escaping () -> Content,
                              text: String = "",
                              duration: CGFloat = 2,
                              isPresented: Binding<Bool>,
                              completion: (() -> Void)? = nil) -> some View {
        let content = AnyView(view())
        let text = text
        let duration = duration
        let completion = completion
    
        return modifier(PopupModifier(content: content,
                                      text: text,
                                      duration: duration,
                                      isPresented: isPresented,
                                      completion: completion))
    }
    
    func popup(icon: Image,
               text: String = "",
               duration: CGFloat = 2,
               isPresented: Binding<Bool>,
               completion: (() -> Void)? = nil) -> some View {
        let icon = icon
        let text = text
        let duration = duration
        let completion = completion
        return modifier(PopupModifier(icon: icon,
                                      text: text,
                                      duration: duration,
                                      isPresented: isPresented,
                                      completion: completion))
    }
}
