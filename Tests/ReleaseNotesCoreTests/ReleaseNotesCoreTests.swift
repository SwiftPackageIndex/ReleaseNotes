@testable import ReleaseNotesCore
import XCTest


final class ReleaseNotesCoreTests: XCTestCase {

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

}
