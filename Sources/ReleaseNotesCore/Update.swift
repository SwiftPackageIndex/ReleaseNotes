struct Update: CustomStringConvertible, Equatable {
    var dependency: String
    var oldRevision: Revision

    var description: String {
        "\(dependency) @ \(oldRevision)"
    }
}
