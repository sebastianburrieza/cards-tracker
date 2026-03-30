/// Non-fatal events that are worth tracking in analytics but don't
/// interrupt the user flow (no error dialog needed).
/// Add new cases as new tracking needs arise.
public enum NonFatalError: Int, CaseIterable {
    case parseError         = 100
    case emptyState         = 101
    case invalidInput       = 102
    case timeout            = 103
}

// MARK: - AnyError

extension NonFatalError: AnyError {
    public var errorCode: Int { rawValue }
    public var name: String { "\(self)" }
}
