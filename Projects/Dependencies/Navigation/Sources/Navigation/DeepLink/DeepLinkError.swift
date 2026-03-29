//  DeepLinkError.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

/// Errors that can occur during deep link or push notification handling.
public enum DeepLinkError: Error {

    /// A required parameter was not found in `queryParameters`.
    case missingParameter(String)

    /// The ``RouterService`` could not build a view controller for the resolved route.
    case unableToNavigate

    /// An unknown or unexpected error occurred during action execution.
    case unknown
}
