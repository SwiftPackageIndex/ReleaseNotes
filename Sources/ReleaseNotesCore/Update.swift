struct Update: CustomStringConvertible, Equatable {
    var packageName: PackageName
    var oldRevision: Revision

    var description: String {
        "\(packageName) @ \(oldRevision)"
    }
}
