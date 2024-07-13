// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreViewModels",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "CoreViewModels",
            targets: ["CoreViewModels"]),
    ],
    dependencies: [
        .package(name: "CoreExtensions", path: "../CoreExtensions"),
        .package(name: "CoreModels", path: "../CoreModels"),
    ],
    targets: [
        .target(
            name: "CoreViewModels",
            dependencies: ["CoreExtensions", "CoreModels"]
        ),
    ]
)
