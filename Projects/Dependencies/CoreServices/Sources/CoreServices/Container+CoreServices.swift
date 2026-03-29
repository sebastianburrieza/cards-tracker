//  Container+CoreServices.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Factory

public extension Container {

    /// Singleton network service shared across all feature repositories.
    ///
    /// Override in unit tests to avoid real network calls:
    /// ```swift
    /// Container.shared.networkService.register { MockNetworkService() }
    /// ```
    var networkService: Factory<any NetworkServiceProtocol> {
        self { URLSessionNetworkService() }.singleton
    }
}
