// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreModels",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "CoreModels",
            targets: ["CoreModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kevinhermawan/OllamaKit.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "CoreModels",
            dependencies: ["OllamaKit"]
        ),
        
    ]
)
