//  CreatePasswordViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import CoreAuth

protocol CreatePasswordNavigationDelegate: AnyObject {
    func passwordCreated()
}

@Observable
final class CreatePasswordViewModel {

    var password: String = ""
    var confirmPassword: String = ""
    var isError: Bool = false
    var errorMessage: String = ""
    var isLoading = false

    @ObservationIgnored
    weak var delegate: (any CreatePasswordNavigationDelegate)?

    @ObservationIgnored
    @Injected(\.authService) private var authService

    func createPassword() {
        guard password.count >= 4 else {
            showError("CREATE_PASSWORD_ERROR_TOO_SHORT".localized)
            return
        }

        guard password == confirmPassword else {
            showError("CREATE_PASSWORD_ERROR_MISMATCH".localized)
            return
        }

        isLoading = true

        do {
            try authService.saveCredentials(password: password)
            delegate?.passwordCreated()
        } catch {
            isLoading = false
            showError("CREATE_PASSWORD_ERROR_SAVE".localized)
        }
    }
    
    private func showError(_ message: String) {
        withAnimation(.smooth(duration: 0.4, extraBounce: 0.2)) {
            errorMessage = message
            isError = true
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
