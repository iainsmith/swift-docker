import Foundation
@testable import SwiftDockerLib
@testable import TSCBasic
import XCTest

class BuiildImageCommandUnitTests: XCTestCase {
  func testSuccessfullBuild() throws {
    let options = CLIOptions(swift: "5.2", path: "/hello/my-Project", verbose: true)
    let fileSystem = InMemoryFileSystem()
    try fileSystem.createDirectory(AbsolutePath("/tmp"))
    let output = MockOutput()
    let shell = MockShell.self
    shell.clear()
    let runner = BuildCommandRunner(
      tag: "iain/DocKer:my-tag",
      options: options,
      fileSystem: fileSystem,
      output: output,
      shell: shell,
      withTemporaryFile: mockWithTemporaryFile
    )

    try runner.run(action: .build)
    XCTAssertEqual(output.lines, [
      "Created temporary Dockerfile at /tmp/Dockerfile",
      "-> docker build",
    ])

    XCTAssertEqual(shell.commands, [
      "docker build -t iain/docker:my-tag --file /tmp/Dockerfile .",
    ])

    let dockerString = try fileSystem.readFileContents(AbsolutePath("/tmp/Dockerfile")).cString
    XCTAssertEqual(try fileSystem.getDirectoryContents(AbsolutePath("/tmp")), ["Dockerfile"])
    XCTAssertEqual(dockerString, """
    FROM swift:5.2
    LABEL com.swiftdockercli.action="build"
    LABEL com.swiftdockercli.folder="my-project"
    COPY . /my-project
    WORKDIR /my-project
    RUN swift build

    """)
  }
}
