// Credit: https://github.com/apple/swift-argument-parser/issues/326#issue-919233547

import ArgumentParser

@available(macOS 11.0, *)
protocol AsyncParsableCommand: ParsableCommand {
    mutating func runAsync() async throws
}

extension ParsableCommand {
    static func main(_ arguments: [String]? = nil) async {
        do {
            var command = try parseAsRoot(arguments)
            if #available(macOS 11.0, *), var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.runAsync()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }
}
