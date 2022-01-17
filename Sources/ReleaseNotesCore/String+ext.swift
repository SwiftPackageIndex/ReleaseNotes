extension String {
    static var gitSuffix = ".git"

    var droppingGitExtension: String {
        if lowercased().hasSuffix(Self.gitSuffix) {
            return String(dropLast(Self.gitSuffix.count))
        }
        return self
    }
}
