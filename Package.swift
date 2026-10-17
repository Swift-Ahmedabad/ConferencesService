// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static var sqliteData: Self {
        product(name: "SQLiteData", package: "sqlite-data")
    }
    static var dependencies: Self {
        product(name: "Dependencies", package: "swift-dependencies")
    }
    static var dependenciesMacros: Self {
        product(name: "DependenciesMacros", package: "swift-dependencies")
    }
    static var dependenciesTestSupport: Self {
        product(name: "DependenciesTestSupport", package: "swift-dependencies")
    }
    static var feedKit: Self {
        product(name: "FeedKit", package: "feedkit")
    }
    static var snapshotTesting: Self {
        product(name: "SnapshotTesting", package: "swift-snapshot-testing")
    }
    static var inlineSnapshotTesting: Self {
        product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing")
    }
    static var sqliteDataTestSupport: Self {
        product(name: "SQLiteDataTestSupport", package: "sqlite-data")
    }
    static var crypto: Self {
        product(name: "Crypto", package: "swift-crypto")
    }
}

let package = Package(
    name: "ConferencesService",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
    ],
    products: [
        .library(
            name: "ConferenceModels",
            targets: ["ConferenceModels"]
        ),
        .library(
            name: "ConferencesService",
            targets: ["ConferencesService"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/pointfreeco/sqlite-data", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/ratnesh-jain/feedkit", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.17.0")),
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .target(
            name: "ConferenceModels",
            dependencies: [.sqliteData, .dependencies, .crypto]
        ),
        .target(
            name: "ConferencesService",
            dependencies: ["ConferenceModels", .sqliteData, .dependencies, .dependenciesMacros, .feedKit]
        ),
        .testTarget(
            name: "ConferencesServiceTests",
            dependencies: [
                "ConferencesService",
                .dependenciesTestSupport,
                .sqliteDataTestSupport,
                .snapshotTesting,
                .inlineSnapshotTesting,
            ],
            resources: [.process("Resources")]
        ),
    ]
)
