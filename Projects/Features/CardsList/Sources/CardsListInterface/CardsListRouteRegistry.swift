//  CardsListRouteRegistry.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Navigation

/// Identifies all navigable destinations exposed by the CardsList feature.
/// Import ``CardsListInterface`` to navigate here from any other module.
public enum CardsListRouteRegistry: String {
    case cardList
}

/// Route that navigates to the cards list screen.
public struct CardsListRoute: Route {

    public static var identifier: String {
        CardsListRouteRegistry.cardList.rawValue
    }

    public init() { }
}
