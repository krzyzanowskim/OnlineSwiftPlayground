// swift-tools-version:5.0
import PackageDescription

let dependencies:[Package.Dependency] = [
    .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.8.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "2.0.0"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.9.0"),
    .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", from: "9.0.0"),
    .package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.4"),
    .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", from: "1.10.0"),
    .package(url: "https://github.com/IBM-Swift/Kitura-Session.git", from: "3.3.0"),
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.4.0"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),
    .package(url: "https://github.com/JohnSundell/Xgen", from: "2.1.0"),
]

var targets:[Target] = [
    .target(name: "PlaygroundServer", dependencies: [ .target(name: "Application"), "Kitura", "HeliumLogger"]),
    .target(name: "Application", dependencies: [ "Kitura", "KituraSession", "Kitura-WebSocket", "Configuration", "CloudEnvironment", "SPMUtility", "KituraStencil", "ZIPFoundation", "Xgen"], exclude: ["DerivedData","static","node_modules"]),
    .testTarget(name: "ApplicationTests" , dependencies: [.target(name: "Application"), "Kitura","HeliumLogger" ])
]

var products: [Product] = [
    .executable(name: "PlaygroundServer", targets: ["PlaygroundServer"])
]

let package = Package(
    name: "PlaygroundServer",
 	  platforms: [
      .macOS(.v10_11)
	  ],
    products: products,
    dependencies: dependencies,
    targets: targets
)
