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

import Parsing
import SemanticVersion


enum Parser {

    static let dependencyStart = Parse(input: Substring.self) {
        Int.parser()
        Skip { " dependenc" }
    }

    static let progressLine = Parse {
        Not { dependencyStart }
        Skip { PrefixThrough("\n") }
    }

    static let progress = Many { progressLine }

    static let dependencyCount = Parse(input: Substring.self) {
        Int.parser()
        Skip {
            OneOf {
                " dependency has changed:"
                " dependencies have changed:"
                " dependencies have changed."
            }
        }
    }

    static let semanticVersion = Parse(Revision.tag) {
        Prefix { $0 != " " }
        .map { (s: Substring) -> String in return String.init(s) }
        .compactMap(SemanticVersion.init)
    }

    static let revision = OneOf {
        semanticVersion
        Prefix { $0 != " " }
            .map(String.init)
            .map(Revision.branch)
    }

    static let newPackageToken: Character = "+"
    static let updatedRevisionToken: Character = "~"
    static let upToStart = Parse(input: Substring.self) {
        Prefix { $0 != newPackageToken && $0 != updatedRevisionToken }
    }

    static let newPackage = Parse { Update(packageId: $0, oldRevision: nil) } with: {
        Skip {
            upToStart
            "\(newPackageToken) "
        }
        Prefix { $0 != " " }.map(String.init)
        Skip {
            Prefix { $0 != "\n" }
        }
    }

    static let updatedRevision = Parse(Update.init(packageId:oldRevision:)) {
        Skip {
            upToStart
            "\(updatedRevisionToken) "
        }
        Prefix { $0 != " " }.map(String.init)
        Skip { " " }
        revision
        Skip {
            " -> "
            Prefix { $0 != "\n" }
        }
    }

    static let update = OneOf {
        updatedRevision
        newPackage
    }

    static let updates = Many(element: { update }, separator: { "\n" })

    static let packageUpdate = Parse {
        Skip { progress }
        Skip { Many { "\n" } }
        dependencyCount
        updates
        Skip { Many { "\n" } }
    }.map { (count: Int, updates: [Update]) in
        assert(updates.count == count)
        return updates
    }

}
