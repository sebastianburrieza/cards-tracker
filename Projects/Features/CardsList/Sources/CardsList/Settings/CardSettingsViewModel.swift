//  CardSettingsViewModel.swift
//  Created by Sebastian Burrieza on 21/04/2026.

import SwiftUI
import Factory
import Utilities
import Extensions
import CoreModels

protocol CardSettingsNavigationDelegate: AnyObject {
    func navigateToPrevious()
    func navigateToLogout()
}

@Observable
final class CardSettingsViewModel {

    let card: Card

    var isPaused: Bool
    var isSubmitting: Bool = false
    var showPopup: Bool = false

    var errorTitle: String?
    var errorMessage: String?
    var isError: Bool = false

    @ObservationIgnored
    weak var delegate: CardSettingsNavigationDelegate?

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    init(card: Card) {
        self.card = card
        self.isPaused = card.isPaused
    }

    // MARK: - Auth

    func logout() {
        delegate?.navigateToLogout()
    }

    // MARK: - Write operations

    func pauseCard() async {
        await MainActor.run {
            withAnimation(.smooth(duration: 0.4, extraBounce: 0.2)) {
                isPaused.toggle()
                isSubmitting = true
                showPopup = true
            }
        }

        let updatedCard = card.copy(isPaused: isPaused)
        let result = await repository.updateCard(updatedCard)

        await MainActor.run {
            if case .failure(let error) = result {
                isPaused.toggle()
                showError(error)
            }
            isSubmitting = false
        }
    }

    func reportCard() async {
        await MainActor.run { isSubmitting = true }

        let result = await repository.updateCard(card)

        await MainActor.run {
            if case .failure(let error) = result {
                showError(error)
            }
            isSubmitting = false
        }
    }

    // MARK: - Formatted values

    var activeBadgeLabel: String {
        isPaused ? "PAUSED".localized : "ACTIVE".localized
    }
    
    var popupText: String {
        isPaused ? "SETTINGS_ACTIVED".localized : "SETTINGS_PAUSED".localized
    }

    var formattedLastFourDigits: String {
        card.lastFourDigits.isEmpty ? "" : "•••• \(card.lastFourDigits)"
    }

    var typeLabel: String {
        switch card.type {
        case .creditPlastic, .creditVirtual: return "CREDIT".localized
        case .debitPlastic, .debitVirtual: return "DEBIT".localized
        case .skeleton, .failure: return ""
        }
    }

    // MARK: - Private

    private func showError(_ error: ServerError? = nil) {
        errorTitle = error?.title ?? "ERROR_TITLE_GENERIC".localized
        errorMessage = error?.message ?? "ERROR_MESSAGE_GENERIC".localized
        isError = true
    }
}
