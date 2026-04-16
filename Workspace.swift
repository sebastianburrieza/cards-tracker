import ProjectDescription
import ProjectDescriptionHelpers

let allProjects = Array(
    Set<Path>(
        Dependency.allCases.map(\.path) +
        Feature.allCases.map(\.path)
    )
)

let allTestsScheme = Scheme.scheme(
    name: "All Tests",
    testAction: .targets(
        [
            .testableTarget(target: .project(path: "Projects/CardsTracker", target: "CardsTrackerTests")),
            .testableTarget(target: .project(path: "Projects/Features/CardsList", target: "CardsListTests")),
            .testableTarget(target: .project(path: "Projects/Features/CardsTransactionDetail", target: "CardsTransactionDetailTests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/CoreModels", target: "CoreModelsTests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/CoreServices", target: "CoreServicesTests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/ComponentsUI", target: "ComponentsUITests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/ResourcesUI", target: "ResourcesUITests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/Navigation", target: "NavigationTests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/Utilities", target: "UtilitiesTests")),
            .testableTarget(target: .project(path: "Projects/Dependencies/Extensions", target: "ExtensionsTests"))
        ],
        options: .options(coverage: true)
    )
)

let workspace = Workspace(
    name: "CardsTracker",
    projects: [.relativeToManifest("Projects/CardsTracker")] + allProjects,
    schemes: [allTestsScheme]
)
