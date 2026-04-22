//  PasswordField.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI

struct PasswordField: View {

    let placeholder: String
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .id("visible")
                } else {
                    SecureField(placeholder, text: $text)
                        .id("secure")
                }
            }
            .foregroundColor(Palette.black.swiftUI)
            .textFieldStyle(.plain)
            .onSubmit { onSubmit?() }

            Button(action: {
                isVisible.toggle()
            }, label: {
                Image(systemName: isVisible ? "eye" : "eye.slash")
                    .foregroundColor(Palette.grayMedium.swiftUI)
                    .frame(width: 24, height: 24)
            })
            .buttonStyle(.plain)
        }
        .padding()
        .background(Palette.backgroundMedium.swiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
