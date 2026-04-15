//  TransactionDetailRouteHandler.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import UIKit
import Navigation
import CardsTransactionDetailInterface

/// Handles route resolution for the CardsTransactionDetail feature.
/// Registered at app startup via ``AppRouter``.
public final class TransactionDetailRouteHandler: RouteHandler {

    public init() { }

    public var routes: [any Route.Type] {
        [TransactionDetailRoute.self]
    }

    @MainActor
    public func build(fromRoute route: (any Route)?) async -> UIViewController? {
        guard let detailRoute = route as? TransactionDetailRoute else { return nil }

        let viewModel = TransactionDetailViewModel(transactionId: detailRoute.transactionId)
        return TransactionDetailViewController(viewModel: viewModel)
    }
}
