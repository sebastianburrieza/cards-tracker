//  CardsTransactionDetailRouteRegistry.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import SwiftUI
import Navigation

/// Identifies all navigable destinations exposed by the CardsTransactionDetail feature.
/// Import ``CardsTransactionDetailInterface`` to navigate here from any other module.
public enum CardsTransactionDetailRouteRegistry: String {
    case transactionDetail
}

/// Route that navigates to the transaction detail bottom sheet.
///
/// Callers populate the display fields so the detail module doesn't depend on
/// any particular networking / model layer.
public struct CardsTransactionDetailRoute: Route {

    public static var identifier: String {
        CardsTransactionDetailRouteRegistry.transactionDetail.rawValue
    }

    public let transactionId: String

    public init(
        transactionId: String,
    ) {
        self.transactionId = transactionId
    }
}
