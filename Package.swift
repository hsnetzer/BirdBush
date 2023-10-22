// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BirdBush",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BirdBush",
            targets: ["BirdBush"]),
    ],
    dependencies: [
      .package(url: "https://github.com/davecom/SwiftPriorityQueue.git", .upToNextMajor(from: "1.4.0")),
      .package(url: "https://github.com/apple/swift-numerics.git", .upToNextMajor(from: "1.0.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BirdBush",
            dependencies: [.product(name: "Numerics", package: "swift-numerics"), .product(name: "SwiftPriorityQueue", package: "SwiftPriorityQueue")]
        ),
        .testTarget(
            name: "BirdBushTests",
            dependencies: ["BirdBush"],
            resources: [.copy("points.json"), .copy("all-the-cities.json")]
        ),
    ]
)
