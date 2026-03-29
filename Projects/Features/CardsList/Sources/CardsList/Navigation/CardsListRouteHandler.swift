//  CardsListRouteHandler.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import Navigation
import CardsListInterface

/// Handles route resolution for the CardsList feature.
/// Registered at app startup via ``AppRouter``.
public final class CardsListRouteHandler: RouteHandler {

    public init() { }

    public var routes: [any Route.Type] {
        [CardsListRoute.self]
    }

    @MainActor
    public func build(fromRoute route: (any Route)?) async -> UIViewController? {
        switch route {
        case is CardsListRoute:
            let viewModel = ListViewModel()
            return ListViewController(viewModel: viewModel)
        default:
            return nil
        }
    }
}
