import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "Utilities",
        dependencies: [Dependency.resourcesUI]
    )
    .build()
