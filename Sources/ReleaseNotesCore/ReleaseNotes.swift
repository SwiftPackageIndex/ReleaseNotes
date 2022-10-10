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


typealias PackageId = String


struct ReleaseNotes: AsyncParsableCommand {

    @Argument
    var workingDirecory: String = "."

    func runAsync() async throws {
        let path = URL(fileURLWithPath: workingDirecory)
            .appendingPathComponent("Package.resolved").path
        guard let packageMap = Self.getPackageMap(at: path) else {
            print("Failed to parse \(path).")
            return
        }

        guard let output = try Self.runPackageUpdate(in: workingDirecory) else {
            print("Package update did not return any changes.")
            return
        }

        let updates: [Update]
        do {
            updates = try Parser.packageUpdate.parse(output)
        } catch {
            print("Failed to parse results from package update.\n")
            print("Please file an issue with the the error output.")
            throw error
        }

        guard !updates.isEmpty else {
            print("No changes.")
            return
        }

        print("\nRelease notes URLs (updating from):")
        for update in updates {
            let releasesURL = packageMap[caseInsensitive: update.packageId]
                .map { $0.absoluteString.droppingGitExtension + "/releases" }
            ?? "\(update.packageId)"
            print(releasesURL, "(\(update.oldRevision?.description ?? "new package"))")
        }
    }

    static func runPackageUpdate(in workingDirecory: String) throws -> String? {
        let process = updateProcess(workingDirecory: workingDirecory)
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

    static func updateProcess(workingDirecory: String) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [
            "-c",
            #"cd "\#(workingDirecory)" && swift package update --dry-run"#,
        ]
        return process
    }

    static func getPackageMap(at path: String) -> [PackageId: URL]? {
        guard FileManager.default.fileExists(atPath: path),
              let json = FileManager.default.contents(atPath: path),
              let packageResolved = try? JSONDecoder()
                .decode(PackageResolved.self, from: json)
        else {
            return nil
        }

        return packageResolved.getPackageMap()
    }

}
