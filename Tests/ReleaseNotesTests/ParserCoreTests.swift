// Copyright 2022 Dave Verwer, Sven A. Schmidt, and other contributors.
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

@testable import ReleaseNotesCore
import XCTest
import Parsing


final class ParserCoreTests: XCTestCase {

    func test_progressLine() throws {
        do {
            var input = "Updating https://github.com/pointfreeco/swift-parsing\n"[...]
            try Parser.progressLine.parse(&input)
        }
        do {
            var input = "Updated https://github.com/apple/swift-argument-parser (0.81s)\n"[...]
            try Parser.progressLine.parse(&input)
        }
        do {
            var input = "Computing version for https://github.com/pointfreeco/swift-parsing\n"[...]
            try Parser.progressLine.parse(&input)
        }
        do {
            var input = "Computed https://github.com/pointfreeco/swift-parsing at 0.4.1 (0.02s)\n"[...]
            try Parser.progressLine.parse(&input)
        }
        do {
            var input = "Creating working copy for https://github.com/JohnSundell/Plot.git\n"[...]
            try Parser.progressLine.parse(&input)
        }
        do {
            var input = "Working copy of https://github.com/JohnSundell/Plot.git resolved at 0.10.0\n"[...]
            try Parser.progressLine.parse(&input)
        }
    }

    func test_anyProgress() throws {
        var input = """
            Updating https://github.com/pointfreeco/swift-parsing
            Updating https://github.com/apple/swift-argument-parser
            Updating https://github.com/SwiftPackageIndex/SemanticVersion
            Updated https://github.com/apple/swift-argument-parser (0.81s)
            Updated https://github.com/pointfreeco/swift-parsing (0.81s)
            Updated https://github.com/SwiftPackageIndex/SemanticVersion (0.81s)
            Computing version for https://github.com/pointfreeco/swift-parsing
            Computed https://github.com/pointfreeco/swift-parsing at 0.4.1 (0.02s)
            Computing version for https://github.com/SwiftPackageIndex/SemanticVersion
            Computed https://github.com/SwiftPackageIndex/SemanticVersion at 0.3.1 (0.01s)
            Computing version for https://github.com/apple/swift-argument-parser
            Computed https://github.com/apple/swift-argument-parser at 1.0.2 (0.01s)
            Creating working copy for https://github.com/JohnSundell/Plot.git
            Working copy of https://github.com/JohnSundell/Plot.git resolved at 0.10.0

            """[...]
        try Skip { Parser.progress }.parse(&input)
    }

    func test_dependencyCount() throws {
        do {
            var input = "1 dependency has changed:"[...]
            XCTAssertEqual(try Parser.dependencyCount.parse(&input), 1)
        }
        do {
            var input = "12 dependencies have changed:"[...]
            XCTAssertEqual(try Parser.dependencyCount.parse(&input), 12)
        }
        do {
            var input = "0 dependencies have changed."[...]
            XCTAssertEqual(try Parser.dependencyCount.parse(&input), 0)
        }
    }

    func test_upToStart() throws {
        do {
            var input = "~ foo"[...]
            XCTAssertNotNil(try? Parser.upToStart.parse(&input))
            XCTAssertEqual(input, "~ foo")
        }
        do {
            var input = "+ foo"[...]
            XCTAssertNotNil(try? Parser.upToStart.parse(&input))
            XCTAssertEqual(input, "+ foo")
        }
        do {
            XCTAssertNotNil(try Parser.upToStart.parse("other"))
        }
    }

    func test_semanticVersion() throws {
        do {
            XCTAssertEqual(try Parser.semanticVersion.parse("1.2.3"), .tag(.init(1, 2, 3)))
        }
        do {
            XCTAssertEqual(try? Parser.semanticVersion.parse("1.2.3-b1"), .tag(.init("1.2.3-b1")!))
        }
    }

    func test_revision() throws {
        do {
            XCTAssertEqual(try Parser.revision.parse("main"), .branch("main"))
        }
    }

    func test_newPackage() throws {
        do {
            XCTAssertEqual(try Parser.newPackage.parse("+ swift-collections 1.0.2"), .init(packageName: "swift-collections"))
        }
        do {
            var input = "~ swift-collections 1.0.2"[...]
            XCTAssertNil(try? Parser.newPackage.parse(&input))
            XCTAssertEqual(input, "~ swift-collections 1.0.2")
        }
    }

    func test_update() throws {
        do {
            var input = #"~ swift-tools-support-core main -> swift-tools-support-core Revision(identifier: "4afd18e40eb028cd9fbe7342e3f98020ea9fdf1a") main"#[...]
            XCTAssertEqual(try Parser.update.parse(&input),
                           .init(packageName: "swift-tools-support-core",
                                 oldRevision: .branch("main")))
        }
        do {
            XCTAssertEqual(try Parser.update.parse(#"~ vapor 4.54.0 -> vapor 4.54.1"#),
                           .init(packageName: "vapor", oldRevision: .tag(.init(4, 54, 0))))
        }
        do {
            XCTAssertEqual(try Parser.update.parse("+ swift-collections 1.0.2"),
                           .init(packageName: "swift-collections"))
        }
    }

    func test_updates() throws {
        do {
            XCTAssertEqual(try Parser.updates.parse(#"~ vapor 4.54.0 -> vapor 4.54.1"#),
                           [.init(packageName: "vapor",
                                 oldRevision: .tag(.init(4, 54, 0)))])
        }
        do {
            XCTAssertEqual(try Parser.updates.parse("+ swift-collections 1.0.2"),
                           [.init(packageName: "swift-collections")])
        }
        do {
            XCTAssertEqual(try Parser.updates.parse("""
                            ~ vapor 4.54.0 -> vapor 4.54.1
                            + swift-collections 1.0.2
                            """),
                           [.init(packageName: "vapor",
                                  oldRevision: .tag(.init(4, 54, 0))),
                            .init(packageName: "swift-collections")])
        }
        do {
            XCTAssertEqual(try Parser.updates.parse("""
                            + swift-collections 1.0.2
                            ~ vapor 4.54.0 -> vapor 4.54.1
                            """),
                           [.init(packageName: "swift-collections"),
                            .init(packageName: "vapor",
                                  oldRevision: .tag(.init(4, 54, 0)))])
        }
    }

    func test_updates_full_list() throws {
        XCTAssertEqual(try Parser.updates.parse("""
            + swift-collections 1.0.2
            ~ swift-tools-support-core main -> swift-tools-support-core Revision(identifier: "4afd18e40eb028cd9fbe7342e3f98020ea9fdf1a") main
            ~ vapor 4.54.0 -> vapor 4.54.1
            ~ swift-nio-ssl 2.17.1 -> swift-nio-ssl 2.17.2
            ~ swift-driver main -> swift-driver Revision(identifier: "fdafa379a28bc1567cc15b67b1fe55aa18ba04de") main
            ~ fluent-kit 1.19.0 -> fluent-kit 1.20.0
            ~ async-kit 1.11.0 -> async-kit 1.11.1
            ~ swift-nio-transport-services 1.11.3 -> swift-nio-transport-services 1.11.4
            ~ SwiftPM main -> SwiftPM Revision(identifier: "49ba6e97a60d1ea4f89c43503c7533e02c6d6913") main
            ~ swift-nio 2.36.0 -> swift-nio 2.37.0
            ~ llbuild main -> llbuild Revision(identifier: "db8311d7d284cae487dff582de980db5a918692f") main
            """), [
            .init(packageName: "swift-collections"),
            .init(packageName: "swift-tools-support-core", oldRevision: .branch("main")),
            .init(packageName: "vapor", oldRevision: .tag(.init(4, 54, 0))),
            .init(packageName: "swift-nio-ssl", oldRevision: .tag(.init(2, 17, 1))),
            .init(packageName: "swift-driver", oldRevision: .branch("main")),
            .init(packageName: "fluent-kit", oldRevision: .tag(.init(1, 19, 0))),
            .init(packageName: "async-kit", oldRevision: .tag(.init(1, 11, 0))),
            .init(packageName: "swift-nio-transport-services", oldRevision: .tag(.init(1, 11, 3))),
            .init(packageName: "SwiftPM", oldRevision: .branch("main")),
            .init(packageName: "swift-nio", oldRevision: .tag(.init(2, 36, 0))),
            .init(packageName: "llbuild", oldRevision: .branch("main")),
        ])
    }

    func test_packageUpdate() throws {
        do {
            XCTAssertEqual(try Parser.packageUpdate.parse(
            """
            10 dependencies have changed:
            ~ swift-tools-support-core main -> swift-tools-support-core Revision(identifier: "4afd18e40eb028cd9fbe7342e3f98020ea9fdf1a") main
            ~ vapor 4.54.0 -> vapor 4.54.1
            ~ swift-nio-ssl 2.17.1 -> swift-nio-ssl 2.17.2
            ~ swift-driver main -> swift-driver Revision(identifier: "fdafa379a28bc1567cc15b67b1fe55aa18ba04de") main
            ~ fluent-kit 1.19.0 -> fluent-kit 1.20.0
            ~ async-kit 1.11.0 -> async-kit 1.11.1
            ~ swift-nio-transport-services 1.11.3 -> swift-nio-transport-services 1.11.4
            ~ SwiftPM main -> SwiftPM Revision(identifier: "49ba6e97a60d1ea4f89c43503c7533e02c6d6913") main
            ~ swift-nio 2.36.0 -> swift-nio 2.37.0
            ~ llbuild main -> llbuild Revision(identifier: "db8311d7d284cae487dff582de980db5a918692f") main
            """
            ).count, 10)
        }
        do {
            XCTAssertEqual(try Parser.packageUpdate.parse(
            """

            0 dependencies have changed.
            """
            ).count, 0)
        }
        do {
            XCTAssertEqual(try Parser.packageUpdate.parse(
            """
            Updating https://github.com/pointfreeco/swift-parsing
            Updating https://github.com/apple/swift-argument-parser
            Updating https://github.com/SwiftPackageIndex/SemanticVersion
            Updated https://github.com/apple/swift-argument-parser (0.81s)
            Updated https://github.com/pointfreeco/swift-parsing (0.81s)
            Updated https://github.com/SwiftPackageIndex/SemanticVersion (0.81s)
            Computing version for https://github.com/pointfreeco/swift-parsing
            Computed https://github.com/pointfreeco/swift-parsing at 0.4.1 (0.02s)
            Computing version for https://github.com/SwiftPackageIndex/SemanticVersion
            Computed https://github.com/SwiftPackageIndex/SemanticVersion at 0.3.1 (0.01s)
            Computing version for https://github.com/apple/swift-argument-parser
            Computed https://github.com/apple/swift-argument-parser at 1.0.2 (0.01s)

            0 dependencies have changed.
            """
            ).count, 0)
        }
    }

    func test_regression_new_package() throws {
        XCTAssertEqual(try Parser.packageUpdate.parse(
        """
        6 dependencies have changed:
        + swift-collections 1.0.2
        ~ fluent-postgres-driver 2.2.2 -> fluent-postgres-driver 2.2.3
        ~ swift-driver main -> swift-driver Revision(identifier: "a034b0bc0cc1366e289e25e00b3e0b21089c98fe") main
        ~ swift-tools-support-core main -> swift-tools-support-core Revision(identifier: "d318eaafe60f20be0f0bbc658793f64bf83847d8") main
        ~ swift-argument-parser 1.0.2 -> swift-argument-parser 1.0.3
        ~ SwiftPM main -> SwiftPM Revision(identifier: "658654765f5a7dfb3456c37dafd3ed8cd8b363b4") main
        """
        ).count, 6)
    }

    func test_progress_resilience() throws {
        // Ensure random output before the dependency count line is ignored
        XCTAssertEqual(try Parser.packageUpdate.parse(
        """
        foo
        bar
        ~ something
        1 dependency has changed:
        ~ fluent-postgres-driver 2.2.2 -> fluent-postgres-driver 2.2.3

        """
        ).count, 1)
    }

    func test_additional_newlines_at_end() throws {
        // Ensure random output before the dependency count line is ignored
        XCTAssertEqual(try Parser.packageUpdate.parse(
        """
        1 dependency has changed:
        ~ fluent-postgres-driver 2.2.2 -> fluent-postgres-driver 2.2.3


        """
        ).count, 1)
    }
}
