// swift-tools-version:5.3
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.2")),
    .package(url: "https://github.com/apple/swift-algorithms", .upToNextMinor(from: "0.0.1")),
    .package(url: "https://github.com/apple/swift-system", .upToNextMinor(from: "0.0.1"))
]

var targets:[Target] = [
    .target(
        name: "OnlinePlayground",
        dependencies: [
            .product(name: "CryptoSwift", package: "CryptoSwift"),
            .product(name: "SystemPackage", package: "swift-system"),
            .product(name: "Algorithms", package: "swift-algorithms")
        ]
    ), // Link custom modules here
]

var products: [Product] = [
    .library(
        name: "OnlinePlayground",
        type: .static,
        targets: [
            "OnlinePlayground"
        ]
    )
]

let package = Package(
    name: "OnlinePlayground",
 	platforms: [.macOS(.v10_12)],
    products: products,
    dependencies: dependencies,
    targets: targets
)
