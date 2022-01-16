// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spi-release-notes",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(name: "swift-argument-parser",
                 url: "https://github.com/apple/swift-argument-parser",
                 from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "release-notes",
            dependencies: ["ReleaseNotesCore"]),
        .target(
            name: "ReleaseNotesCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "ReleaseNotesCoreTests",
            dependencies: ["ReleaseNotesCore"]),
    ]
)
