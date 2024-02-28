// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Stickers",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        .library(
            name: "StickersFeature",
            targets: ["StickersFeature"]),
    ],
    dependencies: [
        .package(url: "https://www.github.com/pointfreeco/swift-composable-architecture", from: "1.8.2"),
    ],
    targets: [
        .target(name: "AppFeature"),
        .target(
            name: "StickersFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
    ]
)
