// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SQLfx",
    platforms: [
        .macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7),
    ],
    products: [
        .library(
            name: "SQLfx",
            targets: ["SQLfx"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/shareup/combine-extensions.git",
            from: "5.0.0"
        ),
        .package(
            url: "https://github.com/shareup/precise-iso-8601-date-formatter.git",
            from: "1.0.2"
        ),
        .package(
            url: "https://github.com/shareup/synchronized.git",
            from: "4.0.0"
        ),
    ],
    targets: [
        .target(
            name: "SQLfx",
            dependencies: [
                .product(
                    name: "PreciseISO8601DateFormatter",
                    package: "precise-iso-8601-date-formatter"
                ),
                .product(name: "Synchronized", package: "synchronized"),
            ]
        ),
        .testTarget(
            name: "SQLfxTests",
            dependencies: [
                .product(name: "CombineExtensions", package: "combine-extensions"),
                .product(name: "CombineTestExtensions", package: "combine-extensions"),
                "SQLfx",
            ]
        ),
    ]
)
