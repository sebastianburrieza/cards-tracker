//  RouterService.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit

/// Defines the interface for configuring, registering route handlers, and navigating to routes.
public protocol RouterServiceProtocol {

    /// Registers a route handler for one or more routes.
    func register(routeHandler: any RouteHandler)

    /// Builds the view controller associated with the given route.
    @MainActor
    func buildController(for route: any Route) async -> UIViewController?

    /// Builds and navigates to the given route using the specified navigation type.
    @MainActor
    func navigate(to route: any Route, fromCoordinator: (any CoordinatorProtocol)?, navigationType: NavigationType) async
}

extension RouterServiceProtocol {
    public func navigate(to route: any Route,
                         fromCoordinator: (any CoordinatorProtocol)? = nil,
                         navigationType: NavigationType) async {
        await navigate(to: route, fromCoordinator: fromCoordinator, navigationType: .push(true))
    }
}

/// Central routing service that maps route identifiers to their handlers.
///
/// Features register their ``RouteHandler`` instances at app startup via ``AppRouter``.
/// Any module can then navigate to a route via the injected ``RouterServiceProtocol``
/// without knowing which feature owns it — enabling decoupled cross-feature navigation
/// and deep link handling.
///
/// **Usage in a DeepLinkAction:**
/// ```swift
/// func performAction() async -> Result<[String: Any], any Error> {
///     await routerService.navigate(to: CardsListRoute())
///     return .success([:])
/// }
/// ```
public final class RouterService: RouterServiceProtocol {

    private var handlers: [String: any RouteHandler] = [:]
    private var failureHandler: ((String) -> Void)?

    /// Configures the instance with a router and optional failure handler.
    /// Must be called from `AppRouter.setup()` before any navigation occurs.
    public init(failureHandler: ((String) -> Void)? = nil) {
        self.failureHandler = failureHandler ?? { _ in }
    }

    // MARK: - Registration

    /// Registers a route handler, mapping each of its declared routes to this handler.
    /// Also triggers ``RouteHandler/registerInternalDependencies()`` for Factory setup.
    public func register(routeHandler: any RouteHandler) {
        routeHandler.registerInternalDependencies()
        for routeType in routeHandler.routes {
            handlers[routeType.identifier] = routeHandler
        }
    }

    // MARK: - Navigation

    /// Builds and returns the view controller for the given route.
    /// Triggers the failure handler if no handler is registered for the route.
    @MainActor
    public func buildController(for route: any Route) async -> UIViewController? {
        let identifier = type(of: route).identifier
        guard let handler = handlers[identifier] else {
            failureHandler?(identifier)
            return nil
        }
        return await handler.build(fromRoute: route)
    }

    /// Builds and immediately navigates to the given route.
    /// Used primarily by ``DeepLinkAction`` implementations to trigger navigation
    /// from any module without a direct reference to the coordinator or router.
    @MainActor
    public func navigate(to route: any Route,
                         fromCoordinator: (any CoordinatorProtocol)?,
                         navigationType: NavigationType = .push(true)) async {
        guard let controller = await buildController(for: route) else { return }

        let navigationController = fromCoordinator?.navigationController ?? UINavigationController()
        performNavigation(to: controller, fromNavigation: navigationController, style: navigationType)
    }
    
    func performNavigation(to controller: UIViewController, fromNavigation: UINavigationController, style navigationType: NavigationType) {
        guard let fromController = fromNavigation.viewControllers.last else { return }
        switch navigationType {
        case .push(let animated):
                fromController.navigationController?.pushViewController(controller, animated: animated)
        case .present(let modalStyle, let animated):
            controller.modalPresentationStyle = modalStyle
            fromController.navigationController?.present(controller, animated: animated)
        case .presentWithAutomaticModal(let animated):
            fromController.navigationController?.present(controller, animated: animated)
        case .setRoot:
            fromNavigation.popToRootViewController(animated: true)
        }
    }
    
}
