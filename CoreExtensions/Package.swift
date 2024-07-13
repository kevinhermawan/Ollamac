// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreExtensions",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "CoreExtensions",
            targets: ["CoreExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/Defaults.git", .upToNextMajor(from: "8.2.0"))
    ],
    targets: [
        .target(
            name: "CoreExtensions",
            dependencies: ["Defaults"]
        ),
    ]
)
