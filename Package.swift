// swift-tools-version:5.5

// Copyright Dave Verwer, Sven A. Schmidt, and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
    name: "swift-release-notes",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(name: "swift-release-notes", targets: ["swift-release-notes"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftPackageIndex/SemanticVersion",
                 from: "0.3.1"),
        .package(url: "https://github.com/apple/swift-argument-parser",
                 from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "swift-release-notes",
            dependencies: ["ReleaseNotesCore"]
        ),
        .target(
            name: "ReleaseNotesCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Parsing", package: "swift-parsing"),
                "SemanticVersion",
            ]
        ),
        .testTarget(
            name: "ReleaseNotesTests",
            dependencies: ["ReleaseNotesCore"],
            exclude: ["Fixtures"]
        ),
    ]
)

#if compiler(<5.8)
package.dependencies.append(
    .package(url: "https://github.com/pointfreeco/swift-parsing", revision: "0.11.0")
)
#else
package.dependencies.append(
    .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.12.0")
)
#endif
