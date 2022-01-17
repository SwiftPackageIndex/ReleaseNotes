import ArgumentParser
import Foundation


struct ReleaseNotes: AsyncParsableCommand {

    @Argument
    var workingDirecory: String = "."

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

        let queue = DispatchQueue(label: "stdout-queue")
        var stdout = ""
        pipe.fileHandleForReading.readabilityHandler = { handler in
            if let str = String(data: handler.availableData, encoding: .utf8) {
                print(str, terminator: "")
                queue.async {
                    stdout += str
                }
            }
        }

        try process.run()
        process.waitUntilExit()

        return stdout
    }

    func updateProcess() -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "-c",
            #"cd "\#(workingDirecory)" && swift package update --dry-run"#,
        ]
        return process
    }

}
