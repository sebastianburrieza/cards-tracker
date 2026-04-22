//  LoginView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities

struct LoginView: View {

    @Bindable var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            Palette.primary.swiftUI
                .ignoresSafeArea()

            VStack(spacing: 32) {
                header
                    .padding(.vertical, 120)
                
                credentialsSection

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

            Text("LOGIN_TITLE".localized)
                .font(Fonts.bold(size: 24))
                .foregroundStyle(Palette.whiteHeavy.swiftUI)
        }
    }

    private var credentialsSection: some View {
        VStack(spacing: 16) {
            Text("LOGIN_SUBTITLE".localized)
                .font(Fonts.medium(size: 17))
                .foregroundStyle(Palette.white.swiftUI)
            
            PasswordField(
                placeholder: "LOGIN_PASSWORD_PLACEHOLDER".localized,
                text: $viewModel.password,
                onSubmit: viewModel.login
            )
            .shake(attempts: viewModel.shakeAttempts)

            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(Fonts.medium(size: 15))
                    .foregroundStyle(Palette.white.swiftUI)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Palette.red.swiftUI)
                    .cornerRadius(25, antialiased: true)
            }

            Button(action: viewModel.login) {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(Palette.white.swiftUI)
                    } else {
                        Text("LOGIN_BUTTON".localized)
                            .font(Fonts.semibold(size: 18))
                            .foregroundStyle(Palette.white.swiftUI)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Palette.orange.swiftUI)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .disabled(viewModel.isLoading)
        }
    }
    

}
