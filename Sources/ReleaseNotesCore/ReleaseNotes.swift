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
            print("Failed to parse results from package update.\n")
            print("Please file an issue with the the output above.")
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
