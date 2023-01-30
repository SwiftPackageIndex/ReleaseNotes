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

import Foundation


enum PackageResolved {
    case v1(V1)
    case v2(V2)

    //    object:
    //      pins:
    //        - package: String
    //          repositoryURL: URL
    //          state:
    //            branch: String?
    //            revision: CommitHash
    //            version: SemVer?
    //        - ...
    //    version: 1
    struct V1: Decodable, Equatable {
        var object: Object

        struct Object: Decodable, Equatable {
            var pins: [Pin]

            struct Pin: Decodable, Equatable {
                var package: String
                var repositoryURL: URL
            }
        }
    }

    //    pins:
    //      - identity: String
    //        location: URL
    //        state:
    //          revision: CommitHash
    //          version: SemVer?
    //      - ...
    //    version: 2
    struct V2: Decodable, Equatable {
        var pins: [Pin]

        struct Pin: Decodable, Equatable {
            var identity: String
            var location: URL
        }
    }
}


extension PackageResolved {
    func getPackageMap() -> [PackageId: URL] {
        switch self {
            case let .v1(value):
                return Dictionary(value.object.pins
                    .map { ($0.package, $0.repositoryURL) },
                                  uniquingKeysWith: { first, _ in first })

            case let .v2(value):
                return Dictionary(value.pins
                    .map { ($0.identity, $0.location) },
                                  uniquingKeysWith: { first, _ in first })
        }
    }
}


extension PackageResolved: Decodable {
    init(from decoder: Decoder) throws {
        if let value = try? decoder.singleValueContainer().decode(V1.self) {
            self = .v1(value)
            return
        }
        if let value = try? decoder.singleValueContainer().decode(V2.self) {
            self = .v2(value)
            return
        }

        throw DecodingError(message: "failed to decode PackageResolved")
    }
}


struct DecodingError: Error {
    var message: String
}
