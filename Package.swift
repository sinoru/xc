// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "xc",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "xc",
            targets: ["xc"]),
        .library(
            name: "XcKit",
            type: .static,
            targets: ["XcKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.5.0"),
        .package(
            url: "https://github.com/apple/swift-atomics",
            from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "xc",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"),
                .product(
                    name: "Atomics",
                    package: "swift-atomics"),
                .target(name: "XcKit"),
            ]),
        .target(name: "XcKit"),
        .testTarget(
            name: "XcKitTests",
            dependencies: ["XcKit"]),
    ]
)
