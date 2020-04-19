@testable import SwiftDockerLib
import XCTest

enum TestError: Error {
  case failed
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
