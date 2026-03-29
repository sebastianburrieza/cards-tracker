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
                "UIAppFonts": .array([
                    .string("Fonts/SF-Pro-Rounded-Heavy.otf"),
                    .string("Fonts/SF-Pro-Rounded-Bold.otf"),
                    .string("Fonts/SF-Pro-Rounded-Medium.otf"),
                    .string("Fonts/SF-Pro-Rounded-Regular.otf"),
                    .string("Fonts/SF-Pro-Rounded-Thin.otf"),
                ]),
            ]),
            sources: ["Sources/CardsTracker/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "Factory"),
                Dependency.navigation.target,
                Feature.cardsList.target
            ]
        ),
        .unitTest(name: "CardsTracker", dependencies: [
            Dependency.navigation.target,
            Feature.cardsList.target
        ])
    ],
    resourceSynthesizers: []
)
