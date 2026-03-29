//  ListCoordinator.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
import Navigation

public final class ListCoordinator: CoordinatorProtocol {

    public enum Steps {
        case home
        case detail(card: Card)
    }
    
    public var childCoordinators = [any CoordinatorProtocol]()
    public var navigationController: UINavigationController
    public var router: RouterProtocol

    public init(navigationController: UINavigationController, router: RouterProtocol) {
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
            return coordinator.start()
        }
    }
    
//    func navigateToRoute(_ route: any RouteType, navigationType: NavigationType) {
//        let controller = build(route)
//        switch navigationType {
//        case .push(let animated):
//            router.push(controller, animated: animated)
//        case .present:
//            router.present(controller, animated: true, modalPresentationStyle: .fullScreen)
//        case .presentWithAutomaticModal(_):
//            router.presentWithAutomaticModal(controller, animated: true)
//        case .setRoot:
//            break
//        }
//    }

//    private func build(_ route: RouteType) -> UIViewController {
//        switch route {
//        case .home:
//            let view = HomeView(router: self)
//            return UIHostingController(rootView: view)
//
//        case .detail(let card):
//            let view = DetailView(id: id, router: self)
//            return UIHostingController(rootView: view)
//        }
//    }
}
