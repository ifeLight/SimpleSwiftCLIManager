// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleSWiftCLIManager",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        // CLIManager module target
        .target(
            name: "CLIManager",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        // CLIManagerExecutable executable target
        .executableTarget(
            name: "CLIManagerExecutable",
            dependencies: [
                "CLIManager",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        // StringCommandExecutable executable target
        .executableTarget(
            name: "StringCommandExecutable",
            dependencies: [
                "CLIManager",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "SimpleSwiftCLIManagerTests",
            dependencies: ["CLIManager"]
        ),
    ]
)
