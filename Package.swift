// swift-tools-version:5.0
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.4.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "2.0.0"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.1"),
    .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "8.0.0"),
    .package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.1"),
    .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", from: "1.10.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-Session.git", from: "3.2.0"),
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.2.1"),
    .package(url: "https://github.com/krzyzanowskim/ZIPFoundation.git", .branch("CZlib")),
    .package(url: "https://github.com/JohnSundell/Xgen", from: "2.1.0"),
]

var targets:[Target] = [
    .target(name: "PlaygroundServer", dependencies: [ .target(name: "Application"), "Kitura", "HeliumLogger"]),
    .target(name: "Application", dependencies: [ "Kitura", "KituraSession", "Kitura-WebSocket", "Configuration", "CloudEnvironment", "Utility", "KituraStencil", "ZIPFoundation", "Xgen"], exclude: ["DerivedData","static","node_modules"]),
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
