import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "Extensions",
        dependencies: [
            Dependency.utilities,
            Dependency.coreModels]
    )
    .build()
