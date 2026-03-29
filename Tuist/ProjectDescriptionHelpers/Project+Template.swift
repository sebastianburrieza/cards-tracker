import ProjectDescription

public let bundlePrefix = "com.cardsTracker"
public let orgName = "CardsTracker"
public let defaultDeploymentTarget = DeploymentTargets.iOS("17.0")

public let projectOptions: Project.Options = .options(
    automaticSchemesOptions: .enabled(codeCoverageEnabled: true),
    disableBundleAccessors: true,
    disableSynthesizedResourceAccessors: true,
    textSettings: .textSettings(
        usesTabs: false,
        indentWidth: 4,
        tabWidth: 4,
        wrapsLines: true
    )
)

// MARK: - CardsTrackerProject

public struct CardsTrackerProject {

    var targets: [Target]
    let name: String

    init(name: String, targets: [Target]) {
        self.name = name
        self.targets = targets
    }

    public func build() -> Project {
        Project(
            name: name,
            organizationName: orgName,
            options: projectOptions,
            targets: targets,
            resourceSynthesizers: []
        )
    }

    /// Framework + Interface + Tests
    public static func frameworkWithInterface(
        name: String,
        dependencies: [DependencyProtocol] = [],
        interfaceDependencies: [DependencyProtocol] = [],
        targetDependencies: [TargetDependency] = [],
        resources: [ResourceFileElement] = []
    ) -> CardsTrackerProject {
        let mapped = dependencies.map(\.target) + targetDependencies
        let interfaceMapped = interfaceDependencies.map(\.target)
        return CardsTrackerProject(
            name: name,
            targets: [
                .framework(name: name, resources: resources, dependencies: [.target(name: "\(name)Interface")] + mapped),
                .framework(name: "\(name)Interface", dependencies: interfaceMapped),
                .unitTest(name: name, dependencies: mapped)
            ]
        )
    }

    /// Framework + Tests (sin Interface)
    public static func singleFramework(
        name: String,
        dependencies: [DependencyProtocol] = [],
        targetDependencies: [TargetDependency] = []
    ) -> CardsTrackerProject {
        let mapped = dependencies.map(\.target) + targetDependencies
        return CardsTrackerProject(
            name: name,
            targets: [
                .framework(name: name, dependencies: mapped),
                .unitTest(name: name, dependencies: mapped)
            ]
        )
    }
}

// MARK: - Target extensions

extension Target {

    public static func framework(
        name: String,
        resources: [ResourceFileElement] = [],
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: name,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name.lowercased())",
            deploymentTargets: defaultDeploymentTarget,
            sources: ["Sources/\(name)/**"],
            resources: .resources(resources),
            scripts: [.swiftLint],
            dependencies: dependencies
        )
    }

    public static func unitTest(
        name: String,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundlePrefix).\(name.lowercased())tests",
            deploymentTargets: defaultDeploymentTarget,
            sources: ["Sources/\(name)Tests/**"],
            scripts: [.swiftLint],
            dependencies: [.target(name: name)] + dependencies
        )
    }
}
