//  ToastErrorView.swift
//  Created by Sebastian Burrieza on 09/09/2025.

import SwiftUI
import ResourcesUI

struct ToastErrorView: View {

    var icon: String?
    var title: String
    var message: String?
    var color: Color
    var duration: Double
    var onDismiss: () -> Void

    @State var isShowing: Bool = false
    @State private var opacity: CGFloat = 0
    @State private var offset: CGFloat = 50

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundStyle(Palette.staticWhite.swiftUI)
                        .opacity(isShowing ? 1 : 0)
                }

                VStack(alignment: .center, spacing: 5) {
                    Text(title)
                        .font(Fonts.medium(size: 15))
                        .foregroundStyle(Palette.staticWhite.swiftUI)
                        .opacity(isShowing ? 1 : 0)

                    if let message = message {
                        Text(message)
                            .font(Fonts.regular(size: 12))
                            .foregroundStyle(Palette.staticWhite.swiftUI)
                            .opacity(isShowing ? 1 : 0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(50, antialiased: true)
            // Swipe down to dismiss
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height > 20 {
                            dismiss()
                        }
                    }
            )
        }
        .offset(y: isShowing ? 0 : offset)
        .opacity(isShowing ? 1 : 0)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(.clear)
        .task {
            animate(true)
            try? await Task.sleep(nanoseconds: UInt64(duration) * 1_000_000_000)
            dismiss()
        }
    }

    @MainActor
    private func dismiss() {
        animate(false)
        // Wait for the dismiss animation to finish before resetting isPresented
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            onDismiss()
        }
    }

    @MainActor
    private func animate(_ show: Bool) {
        switch show {
        case true:
            withAnimation(.bouncy(duration: 0.5)) {
                isShowing = show
                opacity = 1
                offset = 0
            }
        case false:
            withAnimation(.easeOut(duration: 0.3)) {
                isShowing = show
                opacity = 0
                offset = 30
            }
        }
    }

}

struct ToastErrorViewModifier: ViewModifier {

    var icon: String?
    var title: String
    var message: String?
    var color: Color
    var duration: Double
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    ToastErrorView(
                        icon: icon,
                        title: title,
                        message: message,
                        color: color,
                        duration: duration,
                        onDismiss: { isPresented = false }
                    )
                }
            }
            .transition(.opacity)
    }
}

extension View {

    public func toastErrorView(icon: String? = nil,
                               title: String,
                               message: String? = nil,
                               color: Color = Palette.red.swiftUI.opacity(0.9),
                               duration: Double = 2.0,
                               isPresented: Binding<Bool>) -> some View {
        return modifier(ToastErrorViewModifier(icon: icon,
                                               title: title,
                                               message: message,
                                               color: color,
                                               duration: duration,
                                               isPresented: isPresented))
    }
}
