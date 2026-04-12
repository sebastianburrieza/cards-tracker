//  AppRouter.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Factory
import Navigation
import CardsList
import CardsTransactionDetail

/// App-level entry point for all route handler, deep link parser,
/// and Factory dependency registrations.
///
/// Called once during app startup from ``SceneDelegate``.
/// Mirrors the pattern used in large-scale modular apps where each feature
/// registers its own routes and dependencies in isolation.
///
/// To add a new feature:
/// 1. Add its `RouteHandler` instance to ``registerAllRouteHandlers()``
/// 2. Add its `DeepLinkParserProtocol` instance to ``registerAllDeepLinkParsers()``
/// 3. Add any Factory dependencies to ``registerAllDependencies(router:)``
final class AppRouter {

    /// Configures all shared services. Must be called before any navigation occurs.
    ///
    /// - Parameter routerService: The root ``RouterServiceProtocol`` instance created in ``SceneDelegate``.
    static func setup(routerService: RouterServiceProtocol) {
        registerAllDependencies()
        registerAllRouteHandlers()
        registerAllDeepLinkParsers()
    }

    // MARK: - Private

    private static func registerAllRouteHandlers() {
        Container.shared.routerService().register(routeHandler: CardsListRouteHandler())
        Container.shared.routerService().register(routeHandler: CardsTransactionDetailRouteHandler())
    }

    private static func registerAllDeepLinkParsers() {
        let routerService = Container.shared.routerService()
        Container.shared.deepLinkHandler().register(
            parser: CardsListDeepLinkParser(routerService: routerService)
        )
        Container.shared.deepLinkHandler().register(
            parser: CardsTransactionDetailDeepLinkParser(routerService: routerService)
        )
    }

    /// Registers singleton services and configures them with the app's root router.
    /// Add new Factory registrations here as the app grows.
    private static func registerAllDependencies() {

    }
}

// MARK: - Container

extension Container {

    /// Singleton routing service shared across all feature modules.
    var routerService: Factory<any RouterServiceProtocol> {
        self { RouterService() }.singleton
    }

    /// Singleton deep link handler shared across all entry points (SceneDelegate, AppDelegate).
    var deepLinkHandler: Factory<any DeepLinkHandlerProtocol> {
        self { DeepLinkHandler() }.singleton
    }
}
