import UIKit
import Factory
import Navigation
import CoreAuth

public final class AuthCoordinator: CoordinatorProtocol {

    public enum Steps {
        case login
        case createPassword
    }

    public var childCoordinators = [any CoordinatorProtocol]()
    public var navigationController: UINavigationController
    public var router: RouterServiceProtocol

    /// Called when the user successfully authenticates. AppCoordinator uses this
    /// to swap the navigation stack to the main app flow.
    public var onAuthSuccess: (() -> Void)?

    @Injected(\.authService) private var authService

    public init(navigationController: UINavigationController, router: RouterServiceProtocol) {
        self.navigationController = navigationController
        self.router = router
    }

    public func start() -> UIViewController {
        if authService.hasCredentials() {
            return buildController(for: .login)
        } else {
            return buildController(for: .createPassword)
        }
    }

    public func buildController(for step: Steps) -> UIViewController {
        switch step {
        case .login:
            let viewModel = LoginViewModel()
            let controller = LoginViewController(viewModel: viewModel)
            controller.coordinator = self
            return controller

        case .createPassword:
            let viewModel = CreatePasswordViewModel()
            let controller = CreatePasswordViewController(viewModel: viewModel)
            controller.coordinator = self
            return controller
        }
    }

    func loginDidSucceed() {
        onAuthSuccess?()
    }

    func passwordCreated() {
        // After creating a password, push to login so the user logs in immediately
        let loginVC = buildController(for: .login)
        navigationController.setViewControllers([loginVC], animated: true)
    }
}
