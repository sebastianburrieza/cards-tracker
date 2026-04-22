//  LoginViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import Extensions
import CoreAuth

protocol LoginNavigationDelegate: AnyObject {
    func loginDidSucceed()
}

@Observable
final class LoginViewModel {

    var password: String = ""
    var isError: Bool = false
    var errorMessage: String = ""
    var shakeAttempts: Int = 0
    var isLoading = false

    @ObservationIgnored
    weak var delegate: (any LoginNavigationDelegate)?

    @ObservationIgnored
    @Injected(\.authService) private var authService

    func login() {
        guard !password.isEmpty else {
            showError("LOGIN_ERROR_EMPTY".localized)
            return
        }

        isLoading = true

        if authService.login(password: password) {
            delegate?.loginDidSucceed()
        } else {
            isLoading = false
            showError("LOGIN_ERROR_INCORRECT".localized)
        }
    }
    
    private func showError(_ message: String) {
        withAnimation(.smooth(duration: 0.4, extraBounce: 0.2)) {
            errorMessage = message
            isError = true
            shakeAttempts += 1
            resetError()
        }
    }
    
    private func resetError() {
        Task { @MainActor in
            try? await Task.sleep(seconds: 2)
            withAnimation(.smooth(duration: 0.4, extraBounce: 0.2)) {
                errorMessage = ""
                isError = false
            }
        }
    }
}
