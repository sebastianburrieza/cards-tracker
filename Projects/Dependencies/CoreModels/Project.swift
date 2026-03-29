import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "CoreModels",
        dependencies: [
            Dependency.utilities,
            Dependency.resourcesUI
        ])
    .build()
