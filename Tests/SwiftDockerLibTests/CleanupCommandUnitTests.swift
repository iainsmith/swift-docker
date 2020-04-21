import Foundation
@testable import SwiftDockerLib
@testable import TSCBasic
import XCTest

class CleanupCommandUnitTests: XCTestCase {
  var cleanup: CleanupCommand!
  var output: MockOutput!
  var shell: MockShell.Type!

  override func setUp() {
    setupMocks()
  }

  func setupMocks(args: [String] = []) {
    cleanup = try! CleanupCommand.parse(args)
    output = MockOutput()
    shell = MockShell.self
    shell.clear()
    cleanup.shell = shell
    cleanup.terminal = output
  }

  func testNoImagesToCleanup() throws {
    try cleanup.run()
    XCTAssertEqual(output.lines, [
      "No images to delete",
    ])

    XCTAssertEqual(shell.commands, [
      "docker images --filter label=com.swiftdockercli.action=test --quiet",
    ])
  }

  func testDeletingOneImage() throws {
    setupMocks(args: ["--verbose"])
    shell.nextStandardOut = ["123456", "Deleted image 123456"]
    try cleanup.run()
    XCTAssertEqual(output.lines, [
      "Deleted image 123456",
    ])

    XCTAssertEqual(shell.commands, [
      "docker images --filter label=com.swiftdockercli.action=test --quiet",
      "docker rmi 123456 ",
    ])
  }

  func testForceDeletingOneImage() throws {
    setupMocks(args: ["--verbose", "--force"])
    shell.nextStandardOut = ["123456", "Deleted image 123456"]
    try cleanup.run()
    XCTAssertEqual(output.lines, [
      "Deleted image 123456",
    ])

    XCTAssertEqual(shell.commands, [
      "docker images --filter label=com.swiftdockercli.action=test --quiet",
      "docker rmi 123456 --force",
    ])
  }
}
