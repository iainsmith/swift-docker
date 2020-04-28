@testable import SwiftDockerLib
import XCTest

enum TestError: Error {
  case failed
}

struct MockDockerCommand: DockerCommand {
  var options: CLIOptions
  var shell: ShellProtocol.Type = MockShell.self
  var output: OutputDestination = MockOutput()
}

class DockerCommandProtocolTests: XCTestCase {
  func testDockerRunCommandsVapor() {
    let expectedCmd = """
    docker run --rm --mount type=bind,source=/tmp/my-package,target=/package --mount type=volume,source=swiftdockercli-my-package,target=/package/.build --workdir /package  swift:latest swift run --enable-test-discovery Run serve --hostname 0.0.0.0 --env production
    """
    let options = CLIOptions(swift: "latest", path: "/tmp/my-package", verbose: false, clean: false, args: [], seedBuildFolder: false)
    let cmd = MockDockerCommand(options: options)
    let dockerCmd = cmd.makeDockerRunCommand(cmd: "swift run --enable-test-discovery Run serve --hostname 0.0.0.0 --env production", labels: "")
    XCTAssertEqual(dockerCmd, expectedCmd)
  }
}

class DockerImageTests: XCTestCase {
  func testInitailizedWithVersion() throws {
    let version = "4.1"
    guard let destination = DockerTag(version: version, image: nil) else { throw TestError.failed }
    guard case let .officialSwiftVersion(finalVersion) = destination else { throw TestError.failed }
    XCTAssertEqual(finalVersion, "4.1")
  }

  func testInitailizedWithImage() throws {
    let image = "swift:4.1"
    guard let destination = DockerTag(version: nil, image: image) else { throw TestError.failed }
    guard case let .image(fullImage) = destination else { throw TestError.failed }
    XCTAssertEqual(fullImage, "swift:4.1")
  }

  func testInitailizedWithEmptyImage() throws {
    let image = ""
    let version = "4.0"
    guard let destination = DockerTag(version: version, image: image) else { throw TestError.failed }
    guard case let .officialSwiftVersion(finalVersion) = destination else { throw TestError.failed }
    XCTAssertEqual(finalVersion, "4.0")
  }

  func testInitailizationPrecedence() throws {
    let version = "4.1"
    let image = "swift:4.1"
    guard let destination = DockerTag(version: version, image: image) else { throw TestError.failed }
    guard case let .image(fullImage) = destination else { throw TestError.failed }
    XCTAssertEqual(fullImage, "swift:4.1")
  }

  static var allTests = [
    ("testInitailizedWithVersion", DockerImageTests.testInitailizedWithVersion),
    ("testInitailizedWithImage", DockerImageTests.testInitailizedWithImage),
    ("testInitailizedWithEmptyImage", DockerImageTests.testInitailizedWithEmptyImage),
    ("testInitailizationPrecedence", DockerImageTests.testInitailizationPrecedence),
  ]
}
