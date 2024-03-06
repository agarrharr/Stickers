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
            name: "ChartFeature",
            targets: ["ChartFeature"]),
        .library(
            name: "PersonFeature",
            targets: ["PersonFeature"]),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]),
        .library(
            name: "StickersFeature",
            targets: ["StickersFeature"]),
    ],
    dependencies: [
//        .package(url: "https://www.github.com/pointfreeco/swift-composable-architecture", from: "1.8.2"),
        .package(url: "https://www.github.com/pointfreeco/swift-composable-architecture", branch: "shared-state-beta"),
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "ChartFeature",
                "PersonFeature",
                "SettingsFeature",
                "StickersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ChartFeature",
            dependencies: [
                "StickersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "PersonFeature",
            dependencies: [
                "ChartFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "StickersFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
