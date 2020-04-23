import struct Foundation.URL
import TSCBasic

extension FileSystem {
  func exists(_ url: URL) -> Bool {
    exists(try! AbsolutePath(validating: url.path))
  }
}

extension ProcessResult {
  func utf8OutputLines() throws -> [String] {
    try utf8Output().split { $0.isWhitespace }.map(String.init)
  }
}
