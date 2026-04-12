import ProjectDescription

public enum Feature: String, CaseIterable, DependencyProtocol, Sendable {
    case cardsList
    case cardsTransactionDetail

    public var path: Path {
        .relativeToRoot("Projects/Features/\(rawValue.capitalizingFirstLetter())")
    }

    public var targetName: String {
        rawValue.capitalizingFirstLetter()
    }

    public var target: TargetDependency {
        .project(target: targetName, path: path)
    }

    /// References only the lightweight Interface target (e.g. ``CardsTransactionDetailInterface``).
    /// Use this when a feature needs another feature's routes without pulling in the full implementation.
    public var interfaceTarget: TargetDependency {
        .project(target: "\(targetName)Interface", path: path)
    }
}
