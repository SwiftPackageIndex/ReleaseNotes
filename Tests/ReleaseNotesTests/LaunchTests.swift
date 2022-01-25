import XCTest
import class Foundation.Bundle


final class LaunchTests: XCTestCase {

    func test_launch() throws {
        let process = Process()
        process.executableURL = productsDirectory
            .appendingPathComponent("swift-release-notes")
        process.arguments = ["--help"]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertEqual(output, """
            USAGE: release-notes [<working-direcory>]

            ARGUMENTS:
              <working-direcory>      (default: .)

            OPTIONS:
              -h, --help              Show help information.


            """)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

}
