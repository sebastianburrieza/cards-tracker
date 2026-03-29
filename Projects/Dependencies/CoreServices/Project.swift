import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "CoreServices",
        targetDependencies: [
            .external(name: "Factory")
        ]
    )
    .build()
