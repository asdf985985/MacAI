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
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.1.4")
    ],
    targets: [
        .executableTarget(
            name: "SystemMonitor",
            dependencies: [
                "Core",
                "UI",
                "Utils",
                "HotKey"
            ]
        ),
        .target(
            name: "Core",
            dependencies: ["Utils"]
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
            name: "CoreTests",
            dependencies: ["Core"],
            path: "Tests/CoreTests"
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests/UITests"
        ),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"],
            path: "Tests/UtilsTests"
        )
    ]
) 