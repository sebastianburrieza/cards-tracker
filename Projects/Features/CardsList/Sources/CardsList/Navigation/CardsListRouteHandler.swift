//  CardsListRouteHandler.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import Navigation
import CardsListInterface

/// Handles route resolution for the CardsList feature.
/// Registered at app startup via ``AppRouter``.
public final class CardsListRouteHandler: RouteHandler {

    private let routerService: any RouterServiceProtocol

    public init(routerService: any RouterServiceProtocol) {
        self.routerService = routerService
    }

    public var routes: [any Route.Type] {
        [CardsListRoute.self,
         CardDetailRoute.self]
    }

    @MainActor
    public func build(fromRoute route: (any Route)?) async -> UIViewController? {
        switch route {
        case is CardsListRoute:
            let viewModel = ListViewModel()
            return ListViewController(viewModel: viewModel)

        case let cardDetailRoute as CardDetailRoute:
            // Build through the coordinator so internal navigation (e.g. tap a transaction)
            // works correctly even when triggered from a deeplink without a parent coordinator.
            guard let navController = routerService.rootNavigationController else { return nil }
            let coordinator = CardDetailCoordinator(
                navigationController: navController,
                router: routerService,
                card: cardDetailRoute.card
            )
            return coordinator.start()

        default:
            return nil
        }
    }
}
