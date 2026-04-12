import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "CoreServices",
        dependencies: [
            Dependency.coreModels
        ],
        targetDependencies: [
            .external(name: "Factory")
        ]
    )
    .build()
