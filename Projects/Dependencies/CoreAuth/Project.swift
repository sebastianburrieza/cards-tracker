import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .singleFramework(
        name: "CoreAuth",
        targetDependencies: [
            .external(name: "Factory")
        ]
    )
    .build()
