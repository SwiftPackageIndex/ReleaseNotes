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


final class PackageResolvedTests: XCTestCase {

    func test_decode_v1() throws {
        let data = try fixtureData(for: "Package.resolved-v1.json")
        let res = try JSONDecoder().decode(PackageResolved.self, from: data)

        XCTAssertEqual(res.v1?.object.pins.count, 3)
        XCTAssertEqual(res.v2, nil)
    }

    func test_decode_v2() throws {
        let data = try fixtureData(for: "Package.resolved-v2.json")
        let res = try JSONDecoder().decode(PackageResolved.self, from: data)

        XCTAssertEqual(res.v1, nil)
        XCTAssertEqual(res.v2?.pins.count, 5)
    }

    func test_getPackageMap_v1() throws {
        let data = try fixtureData(for: "Package.resolved-v1.json")
        let res = try JSONDecoder().decode(PackageResolved.self, from: data)

        XCTAssertEqual(res.getPackageMap().count, 3)
    }

    func test_getPackageMap_v2() throws {
        let data = try fixtureData(for: "Package.resolved-v2.json")
        let res = try JSONDecoder().decode(PackageResolved.self, from: data)

        XCTAssertEqual(res.getPackageMap().count, 5)
    }

}


private extension PackageResolved {
    var v1: V1? {
        switch self {
            case let .v1(value):
                return value
            case .v2:
                return nil
        }
    }

    var v2: V2? {
        switch self {
            case .v1:
                return nil
            case let .v2(value):
                return value
        }
    }
}


