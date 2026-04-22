import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "CardsTracker",
    organizationName: orgName,
    options: projectOptions,
    targets: [
        .target(
            name: "CardsTracker",
            destinations: .iOS,
            product: .app,
            bundleId: "\(bundlePrefix).app",
            deploymentTargets: defaultDeploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
            ]),
            sources: ["Sources/CardsTracker/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "Factory"),
                Dependency.navigation.target,
                Dependency.coreAuth.target,
                Feature.cardsList.target,
                Feature.cardsTransactionDetail.target,
                Feature.authentication.target
            ]
        ),
        .unitTest(name: "CardsTracker", dependencies: [
            Dependency.navigation.target,
            Feature.cardsList.target,
            Feature.cardsTransactionDetail.target
        ])
    ],
    resourceSynthesizers: []
)
