//  CardSettingsViewController.swift
//  Created by Sebastian Burrieza on 21/04/2026.

import UIKit
import SwiftUI
import CoreModels

final class CardSettingsViewController: UIHostingController<CardSettingsView> {

    var coordinator: CardDetailCoordinator?

    private let viewModel: CardSettingsViewModel

    init(viewModel: CardSettingsViewModel) {
        self.viewModel = viewModel
        super.init(rootView: .init(viewModel: viewModel))
        self.viewModel.delegate = self
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

extension CardSettingsViewController: CardSettingsNavigationDelegate {

    func navigateToPrevious() {
        coordinator?.navigateToPrevious(true)
    }
}
