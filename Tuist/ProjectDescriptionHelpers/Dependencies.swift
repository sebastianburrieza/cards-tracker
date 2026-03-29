import ProjectDescription

/// Represents a module that can be declared as a Tuist target dependency.
public protocol DependencyProtocol: Sendable {
    /// The resolved Tuist target dependency for use in `Project.swift` files.
    var target: TargetDependency { get }
}

public enum Dependency: String, CaseIterable, DependencyProtocol, Sendable {
    case utilities
    case extensions
    case navigation
    case componentsUI
    case coreModels
    case coreServices
    case resourcesUI

    public var path: Path {
        .relativeToRoot("Projects/Dependencies/\(rawValue.capitalizingFirstLetter())")
    }

    public var targetName: String {
        rawValue.capitalizingFirstLetter()
    }

    public var target: TargetDependency {
        .project(target: targetName, path: path)
    }
}

extension String {
    public func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }
}
