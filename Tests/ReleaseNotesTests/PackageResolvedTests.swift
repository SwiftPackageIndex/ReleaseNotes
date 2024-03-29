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

@testable import ReleaseNotesCore
import XCTest


final class ReleaseNotesCoreTests: XCTestCase {

    func test_getPackageMap_v1() throws {
        let path = fixtureUrl(for: "Package.resolved-v1.json").path
        let map = ReleaseNotes.getPackageMap(at: path)

        XCTAssertEqual(map?.count, 3)
    }

    func test_getPackageMap_v2() throws {
        let path = fixtureUrl(for: "Package.resolved-v2.json").path
        let map = ReleaseNotes.getPackageMap(at: path)

        XCTAssertEqual(map?.count, 5)
    }

    func test_Dictionary_subscript_caseInsensitive() throws {
        let d = [
            PackageId("foo"): URL(string: "1")!,
            PackageId("bar"): URL(string: "2")!,
        ]
        XCTAssertEqual(d[caseInsensitive: "foo"], URL(string: "1")!)
        XCTAssertEqual(d[caseInsensitive: "Foo"], URL(string: "1")!)
    }

}
