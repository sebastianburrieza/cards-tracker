//  AppCoordinator.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import Navigation
import CardsList

final class AppCoordinator: CoordinatorProtocol {
    
    enum Steps {
        case list
    }
    
    var childCoordinators = [any CoordinatorProtocol]()
    var navigationController: UINavigationController
    var router: RouterProtocol

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.router = Router(navigationController: navigationController)
    }

    func start() -> UIViewController {
        buildController(for: .list)
    }
    
    func buildController(for step: Steps) -> UIViewController {
        let listCoordinator = ListCoordinator(
            navigationController: navigationController,
            router: router
        )
        return listCoordinator.start()
    }
    
    func navigate(to step: Steps, navigationType: NavigationType) {

    }
    
//    func navigateToRoute(_ route: any RouteType, navigationType: NavigationType) {
//
//    }
}
