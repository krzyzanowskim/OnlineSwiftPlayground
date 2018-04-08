// swift-tools-version:4.0
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.2.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "1.0.0"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.1"),
    .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "6.0.0"),
    .package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", from: "1.8.4"),
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-CredentialsGitHub.git", from: "2.1.0"),
    .package(url: "https://github.com/krzyzanowskim/ZIPFoundation.git", .branch("CZlib")),
    .package(url: "https://github.com/krzyzanowskim/Xgen", .branch("master")),
]

var targets:[Target] = [
    .target(name: "PlaygroundServer", dependencies: [ .target(name: "Application"), "Kitura" , "HeliumLogger"]),
    .target(name: "Application", dependencies: [ "Kitura", "Kitura-WebSocket", "Configuration", "CloudEnvironment", "Utility", "CredentialsGitHub", "KituraStencil", "ZIPFoundation", "Xgen"], exclude: ["DerivedData","static","node_modules"]),
    .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura","HeliumLogger" ])
]

var products: [Product] = [
    .executable(name: "PlaygroundServer", targets: ["PlaygroundServer"])
]

let package = Package(
    name: "PlaygroundServer",
    products: products,
    dependencies: dependencies,
    targets: targets
)
