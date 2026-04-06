/// Represents an error returned by the backend.
/// Repositories return `Result<T, ServerError>` instead of throwing,
/// so ViewModels can handle errors explicitly via `switch result {}`.
public struct ServerError: Error {
    /// Typed error code mapped from the backend `code` field.
    public let code: ServerErrorCode
    /// Short user-facing title (e.g. "Card blocked"). Shown in error dialogs.
    public let title: String?
    /// Detailed user-facing message from the backend.
    public let message: String?
    /// Optional extra context from the backend (e.g. retry-after, field names).
    public let extra: [String: Any]?

    public init(
        _ code: ServerErrorCode,
        title: String? = nil,
        message: String? = nil,
        extra: [String: Any]? = nil
    ) {
        self.code = code
        self.title = title
        self.message = message
        self.extra = extra
    }
}

// MARK: - Convenience

public extension ServerError {
    /// Generic connection error — use when the device is offline or the request timed out.
    static let connection = ServerError(.connectionError,
                                        title: "Connection error",
                                        message: "Check your internet connection and try again.")
    /// Fallback error for unrecognized backend responses.
    static let unexpected = ServerError(.unexpectedError, title: "Something went wrong", message: "Please try again later.")
}

// MARK: - Array helpers

public extension Array where Element == ServerError {
    func containsError(code: ServerErrorCode) -> Bool {
        contains { $0.code == code }
    }
}

// MARK: - AnyError

extension ServerError: AnyError {
    public var errorCode: Int { code.rawValue }
    public var name: String { code.name }
}
