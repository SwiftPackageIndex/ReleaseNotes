// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-release-notes",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(name: "SemanticVersion",
                 url: "https://github.com/SwiftPackageIndex/SemanticVersion",
                 from: "0.3.1"),
        .package(name: "swift-argument-parser",
                 url: "https://github.com/apple/swift-argument-parser",
                 from: "1.0.0"),
        .package(name: "swift-parsing",
                 url: "https://github.com/pointfreeco/swift-parsing", 
                 from: "0.4.1")
    ],
    targets: [
        .executableTarget(
            name: "swift-release-notes",
            dependencies: ["ReleaseNotesCore"]),
        .target(
            name: "ReleaseNotesCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Parsing", package: "swift-parsing"),
                "SemanticVersion"
            ]),
        .testTarget(
            name: "ReleaseNotesCoreTests",
            dependencies: ["ReleaseNotesCore"]),
    ]
)
