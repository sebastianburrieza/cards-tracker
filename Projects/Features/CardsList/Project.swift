import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "CardsList",
        dependencies: [
            Dependency.utilities,
            Dependency.extensions,
            Dependency.navigation,
            Dependency.componentsUI,
            Dependency.resourcesUI,
            Dependency.coreServices
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
