// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "AppStoreConnect-Swift-SDK",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AppStoreConnect-Swift-SDK",
            targets: ["AppStoreConnect-Swift-SDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/schwmi/JWT.git", .upToNextMajor(from: "0.2.0"))
        ],
    targets: [
        .target(
            name: "AppStoreConnect-Swift-SDK",
            dependencies: ["JWT"],
            path: "Sources"),
        .testTarget(
            name: "AppStoreConnect-Swift-SDKTests",
            dependencies: ["AppStoreConnect-Swift-SDK"],
            path: "Example/CocoaPods-AppStoreConnect-Swift-SDK/Tests")
    ]
)
