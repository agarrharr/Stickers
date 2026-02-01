// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Stickers",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "AddChartFeature",
            targets: ["AddChartFeature"]),
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        .library(
            name: "ChartFeature",
            targets: ["ChartFeature"]),
        .library(
            name: "ChartsFeature",
            targets: ["ChartsFeature"]),
        .library(
            name: "Models",
            targets: ["Models"]),
        .library(
            name: "StickerFeature",
            targets: ["StickerFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.10.1"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/sqlite-data", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AddChartFeature",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "ChartsFeature",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ChartFeature",
            dependencies: [
                "StickerFeature",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SQLiteData", package: "sqlite-data"),
            ]
        ),
        .target(
            name: "ChartsFeature",
            dependencies: [
                "AddChartFeature",
                "ChartFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SQLiteData", package: "sqlite-data"),
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SQLiteData", package: "sqlite-data"),
            ]
        ),
        .target(
            name: "StickerFeature",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
            ]
        ),
        .testTarget(
            name: "AddChartFeatureTests",
            dependencies: [
                "AddChartFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "ChartFeatureTests",
            dependencies: [
                "ChartFeature",
                "StickerFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
            ]
        ),
        .testTarget(
            name: "ChartsFeatureTests",
            dependencies: [
                "AddChartFeature",
                "ChartFeature",
                "ChartsFeature",
                "StickerFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
            ]
        ),
    ]
)
