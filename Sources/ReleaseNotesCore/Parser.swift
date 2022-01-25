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
