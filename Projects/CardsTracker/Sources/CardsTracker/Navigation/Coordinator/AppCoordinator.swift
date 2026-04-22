//  AppCoordinator.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import Factory
import Navigation
import CardsList
import Authentication
import CoreAuth

final class AppCoordinator: CoordinatorProtocol {

    enum Steps {
        case auth
        case list
    }

    var childCoordinators = [any CoordinatorProtocol]()
    var navigationController: UINavigationController
    var router: RouterServiceProtocol

    @Injected(\.authService) private var authService

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.router = Container.shared.routerService()
    }

    func start() -> UIViewController {
        if authService.isLoggedIn {
            return buildController(for: .list)
        } else {
            return buildController(for: .auth)
        }
    }

    func buildController(for step: Steps) -> UIViewController {
        switch step {
        case .auth:
            let authCoordinator = AuthCoordinator(
                navigationController: navigationController,
                router: router
            )
            authCoordinator.onAuthSuccess = { [weak self] in
                self?.transitionToMain()
            }
            childCoordinators.append(authCoordinator)
            return authCoordinator.start()

        case .list:
            let listCoordinator = ListCoordinator(
                navigationController: navigationController,
                router: router
            )
            listCoordinator.onLogout = { [weak self] in
                self?.handleLogout()
            }
            childCoordinators.append(listCoordinator)
            return listCoordinator.start()
        }
    }

    func navigate(to step: Steps, navigationType: NavigationType) { }

    // MARK: - Private

    private func transitionToMain() {
        childCoordinators.removeAll()
        let homeVC = buildController(for: .list)
        navigationController.setViewControllers([homeVC], animated: true)
    }

    private func handleLogout() {
        authService.logout()
        childCoordinators.removeAll()
        let loginVC = buildController(for: .auth)
        navigationController.setViewControllers([loginVC], animated: true)
    }
}
