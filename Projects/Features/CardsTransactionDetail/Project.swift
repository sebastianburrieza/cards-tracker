import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "CardsTransactionDetail",
        dependencies: [
            Dependency.utilities,
            Dependency.extensions,
            Dependency.navigation,
            Dependency.componentsUI,
            Dependency.resourcesUI,
            Dependency.coreServices,
            Dependency.coreModels
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
