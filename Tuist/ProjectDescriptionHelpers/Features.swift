import ProjectDescription

public enum Feature: String, CaseIterable, DependencyProtocol, Sendable {
    case cardsList

    public var path: Path {
        .relativeToRoot("Projects/Features/\(rawValue.capitalizingFirstLetter())")
    }

    public var targetName: String {
        rawValue.capitalizingFirstLetter()
    }

    public var target: TargetDependency {
        .project(target: targetName, path: path)
    }
}
