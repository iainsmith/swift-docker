import ArgumentParser
import Foundation
import XCTest

class URLArgumentTests: XCTestCase {
  func testRelativePathResolution() throws {
    let path = URL(argument: "~/Code")!.path
    let expectedPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code").path
    XCTAssertEqual(path, expectedPath)
  }
}
