//  DeepLinkAction.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Represents an action triggered by a deep link or push notification.
///
/// Each feature implements concrete actions conforming to this protocol.
/// An action carries the parameters extracted from the URL or notification payload
/// and is responsible for executing the corresponding app behaviour — which typically
/// involves navigation via ``RouterService/shared``, but can also include
/// data fetching or state updates before navigating.
///
/// **Example:**
/// ```swift
/// final class TransactionDetailDeepLinkAction: DeepLinkAction {
///     var queryParameters: [String: Any]  // ["transactionId": "123"]
///
///     func performAction() async -> Result<[String: Any], any Error> {
///         guard let id = queryParameters["transactionId"] as? String else {
///             return .failure(DeepLinkError.missingParameter("transactionId"))
///         }
///         await RouterService.shared.navigate(to: TransactionDetailRoute(id: id))
///         return .success([:])
///     }
/// }
/// ```
public protocol DeepLinkAction: AnyObject {

    /// Parameters extracted from the deep link URL or notification payload.
    /// e.g. `["transactionId": "123", "cardId": "456"]`
    var queryParameters: [String: Any] { get set }

    /// Executes the action associated with this deep link.
    /// - Returns: `.success` with optional output data, or `.failure` with a descriptive error.
    func performAction() async -> Result<[String: Any], any Error>
}
