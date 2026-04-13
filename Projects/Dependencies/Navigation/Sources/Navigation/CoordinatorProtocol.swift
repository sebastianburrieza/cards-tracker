//  CoordinatorProtocol.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit

/// Defines the contract for a coordinator in the Coordinator pattern.
///
/// Each coordinator owns a navigation flow for a specific feature.
/// It builds view controllers and delegates navigation to the ``RouterProtocol``.
public protocol CoordinatorProtocol: AnyObject {

    /// Represents the possible navigation steps within this coordinator's flow.
    associatedtype Steps

    /// The navigation controller shared across the coordinator hierarchy.
    var navigationController: UINavigationController { get set }

    /// Child coordinators retained to keep them alive during their flow.
    var childCoordinators: [any CoordinatorProtocol] { get set }

    /// The router used to perform the actual navigation actions.
    var router: RouterServiceProtocol { get }

    /// Builds the root view controller for this coordinator's flow.
    func start() -> UIViewController

    /// Navigates back one step in the current flow.
    func navigateToPrevious(_ animated: Bool)

    /// Pops to the root of the navigation stack and clears child coordinators.
    func navigateToRoot(_ animated: Bool)

    /// Navigates to a given step using the specified navigation type.
    func navigate(to step: Steps, navigationType: NavigationType)
    
    /// Navigates to a given Route using the specified navigation type.
    func navigateToRoute(_ route: Route, navigationType: NavigationType) async

    /// Builds the view controller associated with a given step.
    func buildController(for step: Steps) -> UIViewController
}

extension CoordinatorProtocol {
    
    public func navigate(to step: Steps, navigationType: NavigationType = .push(true)) {
        let controller = buildController(for: step)
        
        switch navigationType {
        case .push(let animated):
            navigationController.pushViewController(controller, animated: animated)
        case .present(let style, let animated):
            controller.modalPresentationStyle = style
            navigationController.present(controller, animated: animated)
        case .presentWithAutomaticModal(let animated):
            navigationController.present(controller, animated: animated)
        case .setRoot:
            break
        }
    }
    
    public func navigateToPrevious(_ animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    public func navigateToRoot(_ animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
        childCoordinators.removeAll()
    }
    
    public func navigateToRoute(_ route: Route, navigationType: NavigationType) async {
        await router.navigate(to: route, fromCoordinator: self, navigationType: navigationType)
    }
}
