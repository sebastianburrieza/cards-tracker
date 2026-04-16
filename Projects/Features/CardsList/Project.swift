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
            Dependency.coreServices,
            Dependency.coreModels
        ],
        interfaceDependencies: [
            Dependency.navigation,
            Dependency.coreModels
        ],
        targetDependencies: [
            .external(name: "Factory"),
            Feature.cardsTransactionDetail.interfaceTarget
        ],
        resources: ["Resources/**"]
    )
    .build()
