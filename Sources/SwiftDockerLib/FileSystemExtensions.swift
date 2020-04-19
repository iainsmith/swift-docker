import struct Foundation.URL
import struct TSCBasic.AbsolutePath
import protocol TSCBasic.FileSystem

extension FileSystem {
  func exists(_ url: URL) -> Bool {
    exists(try! AbsolutePath(validating: url.path))
  }
}
