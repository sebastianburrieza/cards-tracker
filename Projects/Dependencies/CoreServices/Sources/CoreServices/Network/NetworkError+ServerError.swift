import CoreModels

extension NetworkError {

    /// Maps a transport-layer error into a domain-level `ServerError`
    /// so repositories can return `Result<T, ServerError>` without
    /// leaking `NetworkError` into the rest of the app.
    public func asServerError() -> ServerError {
        switch self {
        case .invalidURL:
            return ServerError(.unexpectedError, title: "Invalid request")
        case .invalidResponse(let statusCode):
            return ServerError(ServerErrorCode(rawValue: statusCode))
        case .decodingFailed:
            return ServerError(.unexpectedError, title: "Something went wrong")
        case .unknown:
            return .connection
        }
    }
}
