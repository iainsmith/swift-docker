import protocol ArgumentParser.ExpressibleByArgument
import class Foundation.NSString
import struct Foundation.URL

extension URL: ExpressibleByArgument {
  public init?(argument: String) {
    let expanded = NSString(string: argument).expandingTildeInPath
    self = URL(fileURLWithPath: expanded)
  }

  public var defaultValueDescription: String {
    self.relativeString
  }
}
