import ArgumentParser
import Foundation


typealias PackageName = String


struct ReleaseNotes: AsyncParsableCommand {

    @Argument
    var workingDirecory: String = "."

    func runAsync() async throws {
        guard let packageMap = getPackageMap(at: workingDirecory) else {
            print("Failed to parse Package.resolved in \(workingDirecory).")
            return
        }

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

        print("\nRelease notes URLs (updating from):")
        for update in updates {
            let releasesURL = packageMap[update.packageName]
                .map { $0.absoluteString.droppingGitExtension + "/releases" }
            ?? "could not construct releases URL"
            print(releasesURL, "(\(update.oldRevision))")
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

    func getPackageMap(at path: String) -> [PackageName: URL]? {
        //    object:
        //      pins:
        //        - package: String
        //          repositoryURL: URL
        //          state:
        //            branch: String?
        //            revision: CommitHash
        //            version: SemVer?
        //        - ...
        //      version: 1
        struct PackageResolved: Decodable {
            var object: Object

            struct Object: Decodable {
                var pins: [Pin]

                struct Pin: Decodable {
                    var package: String
                    var repositoryURL: URL
                }
            }
        }

        let filePath = URL(fileURLWithPath: path)
            .appendingPathComponent("Package.resolved").path
        guard FileManager.default.fileExists(atPath: filePath),
              let json = FileManager.default.contents(atPath: filePath),
              let packageResolved = try? JSONDecoder()
                .decode(PackageResolved.self, from: json)
        else {
            return nil
        }

        return Dictionary(packageResolved.object.pins
                            .map { ($0.package, $0.repositoryURL) },
                          uniquingKeysWith: { first, _ in first })
    }

}
