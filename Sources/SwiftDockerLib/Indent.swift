extension StringProtocol {
  func indentLines(by spaces: Int) -> String {
    split { $0.isNewline }.map { $0.indent(by: spaces) }.joined(separator: "\n")
  }

  func indent(by spaces: Int) -> String {
    repeatElement(" ", count: spaces).joined(separator: "") + self
  }
}
