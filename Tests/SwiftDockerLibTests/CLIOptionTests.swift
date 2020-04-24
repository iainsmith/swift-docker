import ArgumentParser
import Foundation
@testable import SwiftDockerLib
import TSCBasic
import XCTest

extension CLIOptions {
  static func parseWithoutValidation(_ args: [String]? = nil) throws -> CLIOptions {
    let fullArgs = args ?? []
    return try parse(fullArgs)
  }
}

class CLIOptionTests: XCTestCase {
  func testDefaultDockerTag() throws {
    let options = CLIOptions(path: ".", verbose: true)
    XCTAssertEqual(options.dockerBaseImage, DockerTag.officialSwiftVersion("latest"))
  }

  func testCustomSwiftVersion() throws {
    let options = CLIOptions(swift: "5.1", verbose: true)
    XCTAssertEqual(options.dockerBaseImage, DockerTag.officialSwiftVersion("5.1"))
  }

  func testCustomImage() throws {
    let options = CLIOptions(image: "vapor/ubuntu:latest", verbose: true)
    XCTAssertEqual(options.dockerBaseImage, DockerTag.image("vapor/ubuntu:latest"))
  }

  func testCustomAbsolutePath() throws {
    let options = CLIOptions(path: "/tmp/hello/world", verbose: true)
    XCTAssertEqual(options.absolutePath, AbsolutePath("/tmp/hello/world"))
  }

  func testCustomTildaPath() throws {
    let options = CLIOptions(path: "~/hello/world", verbose: true)
    XCTAssertEqual(options.absolutePath, AbsolutePath("hello/world", relativeTo: localFileSystem.homeDirectory))
  }

  func testRelativePath() throws {
    let options = CLIOptions(path: "../../hello/world", verbose: true)
    let currentDir = localFileSystem.currentWorkingDirectory!
    XCTAssertEqual(options.absolutePath, AbsolutePath("hello/world", relativeTo: currentDir.parentDirectory.parentDirectory))
  }

  func testProjectName() throws {
    let options = CLIOptions(path: "../../hello/world", verbose: true)
    XCTAssertEqual(options.projectName, "world")
  }

  func testValidatesSwiftAndImageAreExclusive() {
    let invalidArgs = ["--image", "vapor/ubuntu:latest", "--swift", "5.1"]
    XCTAssertThrowsError(try CLIOptions.parse(invalidArgs), "--image and --swift were not exclusive")
  }

  func testDirectoryMustContainAPackageSwiftFile() throws {
    try withTemporaryDirectory { dir -> Void in
      try localFileSystem.writeFileContents(dir.appending(component: "Package.swift"), bytes: ByteString())
      XCTAssertNoThrow(try CLIOptions.parse(["--path", dir.pathString]))
    }

    try withTemporaryDirectory { (dir) -> Void in
      XCTAssertThrowsError(try CLIOptions.parse(["--path", dir.pathString]))
    }
  }
}
