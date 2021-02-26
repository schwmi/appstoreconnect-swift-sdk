// swift-tools-version:5.3.0

import PackageDescription

let package = Package(
    name: "AppStoreConnect-Swift-SDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "AppStoreConnect-Swift-SDK", targets: ["AppStoreConnect-Swift-SDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.1.0")
    ],
    targets: [
        .target(name: "AppStoreConnect-Swift-SDK",
                dependencies: [
                    .product(name: "Crypto", package: "swift-crypto")
                ],
                path: "Sources"),
        .testTarget(name: "AppStoreConnect-Swift-SDK-Tests",
                    dependencies: ["AppStoreConnect-Swift-SDK"],
                    path: "Tests",
                    resources: [.process("Models/Fixtures.bundle")])
    ]
)
