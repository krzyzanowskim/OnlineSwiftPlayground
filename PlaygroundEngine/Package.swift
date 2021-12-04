// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "playground",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "PlaygroundEngine",
            targets: ["BuildToolchain", "PlaygroundGenerator"]),
    ],
    dependencies: [
        .package(name: "SwiftPM", url: "https://github.com/apple/swift-package-manager.git", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.11"),
        .package(url: "https://github.com/JohnSundell/Xgen", from: "2.2.0"),
        .package(url: "https://github.com/apple/swift-system", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        .target(
            name: "BuildToolchain",
            dependencies: [
                .product(name: "SPMUtility", package: "SwiftPM"),
                .product(name: "SystemPackage", package: "swift-system")
            ]
        ),
        .target(
            name: "PlaygroundGenerator",
            dependencies: [
                .product(name: "SPMUtility", package: "SwiftPM"),
                "ZIPFoundation",
                "Xgen"
            ]
        )
    ]
)
