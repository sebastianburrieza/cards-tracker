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
    var errorMessage: String?
    var isLoading = false

    @ObservationIgnored
    weak var delegate: (any CreatePasswordNavigationDelegate)?

    @ObservationIgnored
    @Injected(\.authService) private var authService

    func createPassword() {
        guard password.count >= 4 else {
            errorMessage = "CREATE_PASSWORD_ERROR_TOO_SHORT".localized
            return
        }

        guard password == confirmPassword else {
            errorMessage = "CREATE_PASSWORD_ERROR_MISMATCH".localized
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try authService.saveCredentials(password: password)
            delegate?.passwordCreated()
        } catch {
            isLoading = false
            errorMessage = "CREATE_PASSWORD_ERROR_SAVE".localized
        }
    }
}
