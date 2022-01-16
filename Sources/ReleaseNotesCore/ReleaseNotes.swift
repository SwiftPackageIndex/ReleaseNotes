import ArgumentParser
import Foundation


struct ReleaseNotes: AsyncParsableCommand {

    func runAsync() async throws {
        guard let output = try runPackageUpdate() else {
            print("Package update did not return any changes.")
            return
        }

        guard let updates = Parser.packageUpdate.parse(output) else {
            print("Failed to parse results from package update:\n")
            print(output)
            return
        }

        guard !updates.isEmpty else {
            print("No changes.")
            return
        }

        for update in updates {
            print(update)
        }
    }

    func runPackageUpdate() throws -> String? {
        let process = updateProcess()
        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

    func updateProcess() -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swift",
            "package",
            "update",
            "--dry-run"
        ]
        return process
    }

}
