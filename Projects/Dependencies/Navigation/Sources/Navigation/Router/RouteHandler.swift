//  Feature.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation
import UIKit

/// Handles building view controllers for a set of registered routes.
/// Each feature module implements this protocol and declares the routes it owns.
public protocol RouteHandler {

    /// The route types this handler is responsible for.
    var routes: [any Route.Type] { get }

    /// Builds and returns the view controller for the given route.
    /// Returns `nil` if the route is not handled.
    @MainActor
    func build(fromRoute: (any Route)?) async -> UIViewController?

    /// Registers any internal Factory dependencies this feature requires.
    /// Called automatically by ``RouterService`` during handler registration.
    func registerInternalDependencies()
}

public extension RouteHandler {
    func registerInternalDependencies() { }
}
