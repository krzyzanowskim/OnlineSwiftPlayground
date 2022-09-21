// swift-tools-version:5.7
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", .upToNextMinor(from: "0.2.7")),
    .package(url: "https://github.com/JohnSundell/Xgen", .upToNextMinor(from: "2.2.0")),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMinor(from: "0.9.5")),


    .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "4.65.2")),
    .package(url: "https://github.com/vapor/leaf.git", .upToNextMinor(from: "4.2.1")),
]

var targets:[Target] = [
    .target(
        name: "App",
        dependencies: [
            "BuildToolchainEngine",
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "Xgen", package: "xgen"),
            .product(name: "ZIPFoundation", package: "ZIPFoundation"),
            .product(name: "SwiftToolsSupport", package: "swift-tools-support-core")
        ]),
    .target(
        name: "BuildToolchainEngine",
        dependencies: [
            .product(name: "SwiftToolsSupport", package: "swift-tools-support-core")
        ]),
    .executableTarget(
        name: "PlaygroundServer",
        dependencies: [
            "App",
            .product(name: "Vapor", package: "vapor")
        ])
]

var products: [Product] = [
    .library(name: "BuildToolchainEngine", targets: ["BuildToolchainEngine"]),
    .executable(name: "PlaygroundServer", targets: ["PlaygroundServer"])
]

let package = Package(
    name: "PlaygroundServer",
    platforms: [.macOS(.v12)],
    products: products,
    dependencies: dependencies,
    targets: targets
)
