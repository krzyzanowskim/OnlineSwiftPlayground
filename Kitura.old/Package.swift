// swift-tools-version:5.3
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.9.1"),
    .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "2.1.2"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0"),
    .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "9.1.0"),
    .package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.4"),
    .package(name: "KituraStencil", url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", from: "1.10.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-Session.git", from: "3.3.4"),
    .package(name: "SwiftPM", url: "https://github.com/apple/swift-package-manager.git", .upToNextMinor(from: "0.4.0")),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.11"),
    .package(url: "https://github.com/JohnSundell/Xgen", from: "2.2.0"),
]

var targets:[Target] = [
    .target(name: "PlaygroundServer", dependencies: [ .target(name: "Application"), "Kitura", "HeliumLogger"]),
    .target(name: "Application",
            dependencies: [
                "Kitura",
                .product(name: "KituraSession", package: "Kitura-Session"),
                "Kitura-WebSocket",
                "Configuration",
                "CloudEnvironment",
                .product(name: "SPMUtility", package: "SwiftPM"),
                "KituraStencil",
                "ZIPFoundation",
                "Xgen"
            ],
            exclude: ["DerivedData","static","node_modules"]
    ),
    .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura","HeliumLogger" ])
]

var products: [Product] = [
    .executable(name: "PlaygroundServer", targets: ["PlaygroundServer"])
]

let package = Package(
    name: "PlaygroundServer",
 	platforms: [.macOS(.v10_12)],
    products: products,
    dependencies: dependencies,
    targets: targets
)
