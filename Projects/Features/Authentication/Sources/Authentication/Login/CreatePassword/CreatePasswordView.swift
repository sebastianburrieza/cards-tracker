//  CreatePasswordView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ComponentsUI
import ResourcesUI

struct CreatePasswordView: View {

    @Bindable var viewModel: CreatePasswordViewModel

    var body: some View {
        ZStack {
            Palette.orange.swiftUI
                .opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                header
                    .padding(.top, 90)
                    .padding(.bottom, 30)
                
                fieldsSection

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 52))
                .foregroundStyle(Palette.whiteHeavy.swiftUI)

            Text("CREATE_PASSWORD_TITLE".localized)
                .font(Fonts.bold(size: 24))
                .foregroundStyle(Palette.white.swiftUI)
                .multilineTextAlignment(.center)

            Text("CREATE_PASSWORD_SUBTITLE".localized)
                .font(Fonts.medium(size: 19))
                .foregroundStyle(Palette.whiteHeavy.swiftUI)
                .multilineTextAlignment(.center)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            PasswordField(
                placeholder: "CREATE_PASSWORD_PLACEHOLDER".localized,
                text: $viewModel.password
            )

            PasswordField(
                placeholder: "CREATE_PASSWORD_CONFIRM_PLACEHOLDER".localized,
                text: $viewModel.confirmPassword,
                onSubmit: viewModel.createPassword
            )

            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(Fonts.medium(size: 15))
                    .foregroundStyle(Palette.white.swiftUI)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Palette.red.swiftUI)
                    .cornerRadius(25, antialiased: true)
            }

            Button(action: viewModel.createPassword) {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Palette.white.swiftUI)
                    } else {
                        Text("CREATE_PASSWORD_BUTTON".localized)
                            .font(Fonts.semibold(size: 17))
                            .foregroundStyle(Palette.white.swiftUI)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .padding()
                .background(Palette.orange.swiftUI)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .disabled(viewModel.isLoading)
        }
    }
}
