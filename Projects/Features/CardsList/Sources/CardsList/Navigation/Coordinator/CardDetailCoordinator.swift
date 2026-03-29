//  CardDetailCoordinator.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
import Navigation
import CardsListInterface

final class CardDetailCoordinator: CoordinatorProtocol {

    enum Steps {
        case detail
    }
    
    var childCoordinators = [any CoordinatorProtocol]()
    var navigationController: UINavigationController
    var router: RouterProtocol
    private let card: Card

    init(navigationController: UINavigationController, router: RouterProtocol, card: Card) {
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
        }
    }
    
}
