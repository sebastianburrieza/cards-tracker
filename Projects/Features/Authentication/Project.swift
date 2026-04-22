import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "Authentication",
        dependencies: [
            Dependency.navigation,
            Dependency.coreAuth,
            Dependency.componentsUI,
            Dependency.resourcesUI,
            Dependency.utilities
        ],
        interfaceDependencies: [
            Dependency.navigation
        ],
        targetDependencies: [
            .external(name: "Factory")
        ],
        resources: ["Resources/**"]
    )
    .build()
