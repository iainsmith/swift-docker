import Foundation
@testable import SwiftDockerLib
@testable import TSCBasic
import XCTest

class TestCommandUnitTests: XCTestCase {
  func testSuccessfullBuildAndTest() throws {
    let options = CLIOptions(swift: "5.2", path: "/hello/my-project", verbose: true)
    let output = MockOutput()
    let shell = MockShell.self
    shell.clear()
    let runner = TestCommand(
      options: options,
      output: output,
      shell: shell
    )

    try runner.run()
    XCTAssertEqual(output.lines, [
      "Checking for existing docker volume",
      "Creating new docker volume to cache .build folder",
      "-> swift test",
    ])

    XCTAssertEqual(shell.commands, [
      "docker volume ls --quiet --filter label=com.swiftdockercli.folder=my-project",
      "docker volume create --label com.swiftdockercli.folder=my-project --label com.swiftdockercli.action=test swiftdockercli-my-project",
      """
      docker run --rm --mount type=bind,source=/hello/my-project,target=/package \
      --mount type=volume,source=swiftdockercli-my-project,target=/package/.build --workdir /package \
      --label com.swiftdockercli.folder=my-project --label com.swiftdockercli.action=test swift:5.2 swift test
      """
      ]
    )
  }
}
