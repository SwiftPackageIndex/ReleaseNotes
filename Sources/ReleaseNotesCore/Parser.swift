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

import Parsing
import SemanticVersion


enum Parser {

    static let progress = Skip(
        "Updating"
            .orElse("Updated")
            .orElse("Computing")
            .orElse("Computed")
            .orElse("Creating working copy")
            .orElse("Working copy of")
    )
        .skip(Prefix { $0 != "\n"})

    static let anyProgress = Many(progress, separator: "\n")

    static let dependencyCount = Int.parser()
        .skip(
            " dependency has changed:"
                .orElse(" dependencies have changed:")
                .orElse(" dependencies have changed.")
        )

    static let semanticVersion = Prefix(while: { $0 != " " })
        .flatMap { str -> Conditional<Always<Substring, SemanticVersion>, Fail<Substring, SemanticVersion>> in
            if let s = SemanticVersion.init(String(str)) {
                return Conditional.first(Always(s))
            } else {
                return Conditional.second(Fail())
            }
        }
        .map { Revision.tag($0) }

    static let revision = semanticVersion
        .orElse(Prefix { $0 != " " }.map { .branch(String($0)) })

    static let upToTwiddle = Prefix { $0 != "~" }

    static let update = Skip(upToTwiddle)
        .skip("~ ")
        .take(Prefix { $0 != " " }.map(String.init))
        .skip(" ")
        .take(revision)
        .skip(" -> ")
        .skip(Prefix { $0 != "\n" })
        .map(Update.init(packageName:oldRevision:))

    static let updates = Many(update, separator: "\n")

    static let packageUpdate = Skip(anyProgress)
        .skip(Many("\n"))
        .take(dependencyCount)
        .take(updates)
        .map { (count, updates) -> [Update] in
            assert(updates.count == count)
            return updates
        }
    
}
