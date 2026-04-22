//  ListCoordinator.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
import Navigation
import CoreModels

public final class ListCoordinator: CoordinatorProtocol {

    public enum Steps {
        case home
        case detail(card: Card)
    }
    
    public var childCoordinators = [any CoordinatorProtocol]()
    public var navigationController: UINavigationController
    public var router: RouterServiceProtocol

    /// Called when the user logs out from any card's settings screen.
    public var onLogout: (() -> Void)?

    public init(navigationController: UINavigationController, router: RouterServiceProtocol) {
        self.navigationController = navigationController
        self.router = router
    }

    public func start() -> UIViewController {
        buildController(for: .home)
    }

    public func buildController(for step: Steps) -> UIViewController {
        switch step {
        case .home:
            let viewModel = ListViewModel()
            let controller = ListViewController(viewModel: viewModel)
            controller.coordinator = self
            return controller
            
        case .detail(let card):
            let coordinator = CardDetailCoordinator(
                navigationController: navigationController,
                router: router,
                card: card
            )
            coordinator.onLogout = onLogout
            return coordinator.start()
        }
    }
}
