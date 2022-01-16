@testable import ReleaseNotesCore
import XCTest


final class ParserCoreTests: XCTestCase {

    func test_dependencyCount() throws {
        do {
            var input = "1 dependency has changed:"[...]
            XCTAssertEqual(Parser.dependencyCount.parse(&input), 1)
            XCTAssertEqual(input, "")
        }
        do {
            var input = "12 dependencies have changed:"[...]
            XCTAssertEqual(Parser.dependencyCount.parse(&input), 12)
            XCTAssertEqual(input, "")
        }
    }

    func test_semanticVersion() throws {
        do {
            var input = "1.2.3"[...]
            XCTAssertEqual(Parser.semanticVersion.parse(&input),
                           .tag(.init(1, 2, 3)))
            XCTAssertEqual(input, "")
        }
        do {
            var input = "1.2.3-b1"[...]
            XCTAssertEqual(Parser.semanticVersion.parse(&input),
                           .tag(.init("1.2.3-b1")!))
            XCTAssertEqual(input, "")
        }
    }

    func test_revision() throws {
        do {
            var input = "1.2.3"[...]
            XCTAssertEqual(Parser.revision.parse(&input), .tag(.init(1, 2, 3)))
            XCTAssertEqual(input, "")
        }
        do {
            var input = "main"[...]
            XCTAssertEqual(Parser.revision.parse(&input), .branch("main"))
            XCTAssertEqual(input, "")
        }
    }

    func test_update() throws {
        do {
            var input = #"~ swift-tools-support-core main -> swift-tools-support-core Revision(identifier: "4afd18e40eb028cd9fbe7342e3f98020ea9fdf1a") main"#[...]
            XCTAssertEqual(Parser.update.parse(&input),
                           .init(dependency: "swift-tools-support-core",
                                 oldRevision: .branch("main")))
        }
        do {
            var input = #"~ vapor 4.54.0 -> vapor 4.54.1"#[...]
            XCTAssertEqual(Parser.update.parse(&input),
                           .init(dependency: "vapor", oldRevision: .tag(.init(4, 54, 0))))
        }
    }

    func test_updates() throws {
        var input = """
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
            """[...]
        XCTAssertEqual(Parser.updates.parse(&input), [
            .init(dependency: "swift-tools-support-core", oldRevision: .branch("main")),
            .init(dependency: "vapor", oldRevision: .tag(.init(4, 54, 0))),
            .init(dependency: "swift-nio-ssl", oldRevision: .tag(.init(2, 17, 1))),
            .init(dependency: "swift-driver", oldRevision: .branch("main")),
            .init(dependency: "fluent-kit", oldRevision: .tag(.init(1, 19, 0))),
            .init(dependency: "async-kit", oldRevision: .tag(.init(1, 11, 0))),
            .init(dependency: "swift-nio-transport-services", oldRevision: .tag(.init(1, 11, 3))),
            .init(dependency: "SwiftPM", oldRevision: .branch("main")),
            .init(dependency: "swift-nio", oldRevision: .tag(.init(2, 36, 0))),
            .init(dependency: "llbuild", oldRevision: .branch("main")),
        ])
    }

    func test_packageUpdate() throws {
        var input = """
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
            """[...]
        XCTAssertEqual(Parser.packageUpdate.parse(&input)?.count, 10)
    }

}
