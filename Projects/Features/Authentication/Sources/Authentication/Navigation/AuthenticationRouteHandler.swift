import UIKit
import Navigation
import AuthenticationInterface

public final class AuthenticationRouteHandler: RouteHandler {

    private let routerService: any RouterServiceProtocol

    public init(routerService: any RouterServiceProtocol) {
        self.routerService = routerService
    }

    public var routes: [any Route.Type] {
        [LoginRoute.self, CreatePasswordRoute.self]
    }

    @MainActor
    public func build(fromRoute route: (any Route)?) async -> UIViewController? {
        guard let navController = routerService.rootNavigationController else { return nil }

        switch route {
        case is LoginRoute:
            let coordinator = AuthCoordinator(navigationController: navController, router: routerService)
            return coordinator.start()

        case is CreatePasswordRoute:
            let viewModel = CreatePasswordViewModel()
            return CreatePasswordViewController(viewModel: viewModel)

        default:
            return nil
        }
    }
}
