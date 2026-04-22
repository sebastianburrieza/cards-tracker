//  Container+CoreAuth.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Factory

public extension Container {
    var authService: Factory<any AuthServiceProtocol> {
        self { AuthService() }.singleton
    }
}
