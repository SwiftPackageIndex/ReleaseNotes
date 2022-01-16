import SemanticVersion


enum Revision: CustomStringConvertible, Equatable {
    case tag(SemanticVersion)
    case branch(String)

    var description: String {
        switch self {
            case .tag(let v):
                return "\(v)"
            case .branch(let b):
                return b
        }
    }
}
