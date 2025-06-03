// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SystemMonitor",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SystemMonitor",
            targets: ["SystemMonitor"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.1.4"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/johnxnguyen/Down.git", from: "0.11.0"),
    ],
    targets: [
        .executableTarget(
            name: "SystemMonitor",
            dependencies: [
                "Core",
                "UI",
                "Utils",
                "HotKey",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "Input",
            dependencies: []
        ),
        .target(
            name: "Core",
            dependencies: [
                "Utils",
                "Input",
                .product(name: "Down", package: "Down")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "UI",
            dependencies: ["Core", "Utils", "HotKey"]
        ),
        .target(
            name: "Utils",
            dependencies: []
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"],
            path: "Tests/UtilsTests"
        )
    ]
) 