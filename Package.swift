// swift-tools-version:5.3.0

import PackageDescription

let package = Package(
    name: "AppStoreConnect-Swift-SDK",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "AppStoreConnect-Swift-SDK", targets: ["AppStoreConnect-Swift-SDK"])
    ],
    dependencies: [],
    targets: [
        .testTarget(name: "AppStoreConnect-Swift-SDK-Tests",
                    dependencies: ["AppStoreConnect-Swift-SDK"],
                    path: "Tests",
                    exclude: ["LinuxMain.swift"],
                    resources: [.process("Models/Fixtures.bundle")]),
        .target(name: "AppStoreConnect-Swift-SDK", path: "Sources")
    ]
)
