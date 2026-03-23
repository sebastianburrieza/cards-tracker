// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Factory": .framework
    ]
)
#endif

let package = Package(
    name: "CardsTracker",
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory", from: "2.4.0")
    ]
)
