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
            ]),
            sources: ["CardsTracker/Sources/**"],
            resources: ["CardsTracker/Resources/**"]
        )
    ]
)
