/// A common interface for all error types in the app.
/// Conforming to this protocol allows errors to be forwarded
/// to analytics and logging systems in a uniform way.
public protocol AnyError {
    /// Numeric code identifying the error (used for analytics).
    var errorCode: Int { get }
    /// Human-readable name of the error (used for logging).
    var name: String { get }
}
