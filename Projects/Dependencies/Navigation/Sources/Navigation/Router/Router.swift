//  Router.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit

/// Abstracts UINavigationController navigation so coordinators
/// are not coupled to a concrete implementation.
public protocol RouterProtocol: AnyObject {

    /// Pushes a view controller onto the navigation stack.
    func push(_ controller: UIViewController, animated: Bool)

    /// Pops the top view controller from the navigation stack.
    func pop(animated: Bool)

    /// Presents a view controller modally with a given presentation style.
    func present(_ controller: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle)

    /// Presents a view controller using the system-inferred modal style.
    func presentWithAutomaticModal(_ controller: UIViewController, animated: Bool)

    /// Dismisses the currently presented view controller.
    func dismiss(animated: Bool, completion: (() -> Void)?)
    
    func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController?,
        navigationType: NavigationType)
}

/// Concrete implementation of ``RouterProtocol``.
///
/// Wraps a `UINavigationController` with a `weak` reference to avoid retain cycles.
/// All navigation actions are delegated to the underlying navigation controller.
public final class Router: RouterProtocol {

    /// Held as `weak` to avoid retaining the navigation hierarchy.
    private weak var navigationController: UINavigationController?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func push(_ controller: UIViewController, animated: Bool) {
        navigationController?.pushViewController(controller, animated: animated)
    }

    public func pop(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }

    public func present(_ controller: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle) {
        controller.modalPresentationStyle = modalPresentationStyle
        navigationController?.present(controller, animated: animated)
    }

    public func presentWithAutomaticModal(_ controller: UIViewController, animated: Bool) {
        controller.modalPresentationStyle = .automatic
        navigationController?.present(controller, animated: animated)
    }

    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController?.dismiss(animated: animated, completion: completion)
    }

    /// Resolves the navigation type and delegates to the appropriate method.
    /// The `fromView` parameter is the already-built destination view controller.
    public func navigate(toRoute route: any Route, fromView controller: UIViewController?, navigationType: NavigationType) {
        Task { @MainActor in
            guard let controller else { return }
            switch navigationType {
            case .push(let animated):
                push(controller, animated: animated)
            case .present(let modalStyle, let animated):
                present(controller, animated: animated, modalPresentationStyle: modalStyle)
            case .presentWithAutomaticModal(let animated):
                presentWithAutomaticModal(controller, animated: animated)
            case .setRoot:
                break
            }
        }
    }
}
