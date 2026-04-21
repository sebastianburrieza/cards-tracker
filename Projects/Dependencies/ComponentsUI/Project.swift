import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "ComponentsUI",
        dependencies: [
            Dependency.utilities,
            Dependency.resourcesUI,
            Dependency.extensions
        ]
    )
    .build()
