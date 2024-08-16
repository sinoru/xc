// swift-tools-version: 5.9

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
            targets: ["XcKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.5.0"),
        .package(
            url: "https://github.com/apple/swift-atomics",
            from: "1.2.0"),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            "1.0.0" ..< "4.0.0"
        ),
        .package(
            url: "https://github.com/sinoru/swift-json-value",
            from: "0.0.5"),
    ],
    targets: [
        .executableTarget(
            name: "xc",
            dependencies: [
                .product(
                    name: "Atomics",
                    package: "swift-atomics"),
                .target(name: "XcKit"),
                .target(name: "XcArgument"),
            ]),
        .target(
            name: "XcArgument",
            dependencies: [
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"),
            ]),
        .target(
            name: "XcApple",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "JSONValue", package: "swift-json-value"),
            ]),
        .target(name: "XcKit"),
        .testTarget(
            name: "XcAppleTests",
            dependencies: ["XcApple"]),
        .testTarget(
            name: "XcKitTests",
            dependencies: ["XcKit"]),
    ]
)
