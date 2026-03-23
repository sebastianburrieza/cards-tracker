import ProjectDescription

let project = Project(
    name: "CardsTracker",
    targets: [
        .target(
            name: "CardsTracker",
            destinations: .iOS,
            product: .app,
            bundleId: "com.cardsTracker.app",
            deploymentTargets: .iOS("17.0"),
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
            sources: ["CardsTracker/Sources/**"],
            resources: ["CardsTrackerResources/**"],
            dependencies: [
                .external(name: "Factory")
            ]
        ),
        .target(
            name: "CardsTrackerTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.cardsTracker.app.tests",
            deploymentTargets: .iOS("17.0"),
            sources: ["CardsTrackerTests/Sources/**"],
            dependencies: [
                .target(name: "CardsTracker")
            ]
        )
    ]
)
