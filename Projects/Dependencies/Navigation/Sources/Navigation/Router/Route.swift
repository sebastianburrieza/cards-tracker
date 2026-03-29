//  RouteType.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Represents a navigable destination in the app.
///
/// Each feature exposes its entry points by declaring a struct that conforms to `Route`.
/// The ``RouterService`` uses the `identifier` to look up the correct ``RouteHandler``
/// and build the corresponding view controller.
public protocol Route {

    /// A unique string that identifies this route across all feature modules.
    /// Used as the key in the ``RouterService`` handler registry.
    static var identifier: String { get }
}

/// Declares the set of routes a feature module exposes to the ``RouterService``.
///
/// Each feature implements this protocol to advertise which ``Route`` types
/// it can handle, allowing the app to register them at startup via ``RouteRegisterProtocol``.
public protocol RouteRegister {

    /// The route types this module can handle.
    var routes: [Route.Type] { get }
}

/// Defines the registration entry point for adding feature routes to the ``RouterService``.
///
/// Implemented by the ``RouterService`` to accept ``RouteRegister`` instances
/// from each feature module during app startup.
public protocol RouteRegisterProtocol {

    /// Registers all routes declared by the given `RouteRegister`.
    func register(routeRegister: RouteRegister)
}
