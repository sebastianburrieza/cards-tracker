import ProjectDescription
import ProjectDescriptionHelpers

let allProjects = Array(
    Set<Path>(
        Dependency.allCases.map(\.path) +
        Feature.allCases.map(\.path)
    )
)

let workspace = Workspace(
    name: "CardsTracker",
    projects: [.relativeToManifest("Projects/CardsTracker")] + allProjects
)
