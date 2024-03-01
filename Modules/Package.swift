// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Stickers",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AddSticker",
            targets: ["AddSticker"]),
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        .library(
            name: "ChartFeature",
            targets: ["ChartFeature"]),
        .library(
            name: "PeopleButtons",
            targets: ["PeopleButtons"]),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]),
        .library(
            name: "StickersFeature",
            targets: ["StickersFeature"]),
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    dependencies: [
//        .package(url: "https://www.github.com/pointfreeco/swift-composable-architecture", from: "1.8.2"),
        .package(url: "https://www.github.com/pointfreeco/swift-composable-architecture", branch: "shared-state-beta"),
        .package(url: "https://www.github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AddSticker",
            dependencies: [
                "ChartFeature",
                "Models",
                "PeopleButtons",
                "StickersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "AddSticker",
                "ChartFeature",
                "Models",
                "PeopleButtons",
                "SettingsFeature",
                "StickersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ChartFeature",
            dependencies: [
                "Models",
                "StickersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "PeopleButtons",
            dependencies: [
                "Models",
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
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
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]
        ),
    ]
)
