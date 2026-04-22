import Navigation

public enum AuthenticationRouteRegistry: String {
    case login
    case createPassword
}

public struct LoginRoute: Route {
    public static var identifier: String {
        AuthenticationRouteRegistry.login.rawValue
    }
    public init() {}
}

public struct CreatePasswordRoute: Route {
    public static var identifier: String {
        AuthenticationRouteRegistry.createPassword.rawValue
    }
    public init() {}
}
