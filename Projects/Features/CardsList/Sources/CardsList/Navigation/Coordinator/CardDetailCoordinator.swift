//  CardDetailCoordinator.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
import CoreModels
import Navigation
import CardsListInterface
import CardsTransactionDetailInterface

final class CardDetailCoordinator: CoordinatorProtocol {

    enum Steps {
        case detail
        case settings
    }
    
    var childCoordinators = [any CoordinatorProtocol]()
    var navigationController: UINavigationController
    var router: RouterServiceProtocol
    private let card: Card

    init(navigationController: UINavigationController, router: RouterServiceProtocol, card: Card) {
        self.navigationController = navigationController
        self.router = router
        self.card = card
    }

    func start() -> UIViewController {
        buildController(for: .detail)
    }
    
    func buildController(for step: Steps) -> UIViewController {
        switch step {
        case .detail:
            let viewModel = CardDetailViewModel(card: card)
            let controller = CardDetailViewController(viewModel: viewModel)
            controller.coordinator = self
            return controller
        case .settings:
            let viewModel = CardSettingsViewModel(card: card)
            let controller = CardSettingsViewController(viewModel: viewModel)
            controller.coordinator = self
            return controller
        }
    }

    func navigateToSettings() {
        let controller = buildController(for: .settings)
        navigationController.pushViewController(controller, animated: true)
    }

}
