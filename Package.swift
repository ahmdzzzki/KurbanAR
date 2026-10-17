// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KurbanCore",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [.library(name: "KurbanCore", targets: ["KurbanCore"])],
    targets: [.target(name: "KurbanCore"), .testTarget(name: "KurbanCoreTests", dependencies: ["KurbanCore"])]
)
