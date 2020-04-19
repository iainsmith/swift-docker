import Foundation
@testable import SwiftDockerLib
@testable import TSCBasic
import XCTest

class CleanupCommandUnitTests: XCTestCase {
  func testNoImagesToCleanup() throws {
    let output = MockOutput()
    let shell = MockShell.self
    shell.clear()
    let runner = CleanupCommandRunner(verbose: true, terminal: output, shell: shell)
    try runner.run()
    XCTAssertEqual(output.lines, [
      "No images to delete",
    ])

    XCTAssertEqual(shell.commands, [
      "docker images --filter label=com.swiftdockercli.action=test --quiet",
    ])
  }

  func testDeletingOneImage() throws {
    let output = MockOutput()
    let shell = MockShell.self
    shell.clear()
    let runner = CleanupCommandRunner(verbose: true, terminal: output, shell: shell)
    shell.nextStandardOut = ["123456", "Deleted image 123456"]
    try runner.run()
    XCTAssertEqual(output.lines, [
      "Deleted image 123456",
    ])

    XCTAssertEqual(shell.commands, [
      "docker images --filter label=com.swiftdockercli.action=test --quiet",
      "docker rmi 123456 ",
    ])
  }

  func testForceDeletingOneImage() throws {
    let output = MockOutput()
    let shell = MockShell.self
    shell.clear()
    let runner = CleanupCommandRunner(verbose: true, force: true, terminal: output, shell: shell)
    shell.nextStandardOut = ["123456", "Deleted image 123456"]
    try runner.run()
    XCTAssertEqual(output.lines, [
      "Deleted image 123456",
    ])

    XCTAssertEqual(shell.commands, [
      "docker images --filter label=com.swiftdockercli.action=test --quiet",
      "docker rmi 123456 --force",
    ])
  }
}
