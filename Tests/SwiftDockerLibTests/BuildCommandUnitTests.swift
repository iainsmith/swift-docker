import Foundation
@testable import SwiftDockerLib
@testable import TSCBasic
import XCTest

class TestCommandUnitTests: XCTestCase {
  func testSuccessfullBuildAndTest() throws {
    let options = try CLIOptions.parse(["--swift", "5.2", "--path", "/hello/my-project", "-v", "--skip-validation"])
    let fileSystem = InMemoryFileSystem()
    try fileSystem.createDirectory(AbsolutePath("/tmp"))
    let output = MockOutput()
    let shell = MockShell.self
    shell.clear()
    let runner = TestCommandRunner(
      options: options,
      fileSystem: fileSystem,
      output: output,
      shell: shell,
      withTemporaryFile: mockWithTemporaryFile,
      computeGitSHA: { "4E3FF7" }
    )

    try runner.run()
    XCTAssertEqual(output.lines, [
      "Created temporary Dockerfile at /tmp/Dockerfile",
      "-> docker build",
      "-> swift test",
    ])

    XCTAssertEqual(shell.commands, [
      "docker build -t swift-docker/my-project:4e3ff7 --file /tmp/Dockerfile .",
      "docker run --rm swift-docker/my-project:4e3ff7 swift test",
    ])

    let dockerString = try fileSystem.readFileContents(AbsolutePath("/tmp/Dockerfile")).cString
    XCTAssertEqual(try fileSystem.getDirectoryContents(AbsolutePath("/tmp")), ["Dockerfile"])
    XCTAssertEqual(dockerString, """
    FROM swift:5.2
    LABEL com.swiftdockercli.action="test"
    LABEL com.swiftdockercli.folder="my-project"
    COPY . /my-project
    WORKDIR /my-project
    RUN swift build

    """)
  }
}
