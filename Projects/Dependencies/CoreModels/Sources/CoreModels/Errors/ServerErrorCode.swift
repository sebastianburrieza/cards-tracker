/// All possible error codes returned by the backend.
/// Raw values map to the numeric `code` field in the API error response.
/// Add new cases here as new backend error codes are documented.
public enum ServerErrorCode: Int, CaseIterable {

    // MARK: - Generic (client-side)
    case unexpectedError    = -2
    case connectionError    = -1

    // MARK: - Auth
    case unauthorized       = 401
    case forbidden          = 403

    // MARK: - Cards
    case cardNotFound       = 1001
    case cardBlocked        = 1002
    case cardExpired        = 1003

    // MARK: - Transactions
    case transactionNotFound    = 2001
    case insufficientFunds      = 2002
    case transactionLimitExceeded = 2003

    /// Maps a raw backend code to a case. Falls back to `.unexpectedError`
    /// for unrecognized codes so nothing crashes on new backend values.
    public init(rawValue: Int) {
        self = ServerErrorCode.allCases.first { $0.rawValue == rawValue } ?? .unexpectedError
    }
}

// MARK: - AnyError

extension ServerErrorCode: AnyError {
    public var errorCode: Int { rawValue }
    public var name: String { "\(self)" }
}
