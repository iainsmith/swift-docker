@testable import SwiftDockerLib
@testable import TSCBasic

class MockShell: ShellProtocol {
  static var commands = [String]()
  static var nextStandardOut: [String] = []

  static func runWithStreamingOutput(_ cmd: String, controller _: OutputDestination, redirection _: OutputRewriter.Type, isVerbose _: Bool) throws -> ProcessResult {
    commands.append(cmd)
    let arguments = cmd.split { $0.isNewline }.map { String($0) }
    let byteArray = nextStandardOut.first.flatMap { ByteString(encodingAsUTF8: $0)._bytes } ?? []
    let result = ProcessResult(arguments: arguments, environment: [:], exitStatus: .terminated(code: 0), output: .success(byteArray), stderrOutput: .success([]))
    nextStandardOut = Array(nextStandardOut.dropFirst())
    return result
  }

  static func run(_ cmd: String, outputDestination _: OutputDestination?, isVerbose _: Bool) throws -> ProcessResult {
    commands.append(cmd)
    let arguments = cmd.split { $0.isNewline }.map { String($0) }
    let byteArray = nextStandardOut.first.flatMap { ByteString(encodingAsUTF8: $0)._bytes } ?? []
    let result = ProcessResult(arguments: arguments, environment: [:], exitStatus: .terminated(code: 0), output: .success(byteArray), stderrOutput: .success([]))
    nextStandardOut = Array(nextStandardOut.dropFirst())
    return result
  }

  static func clear() {
    Self.commands = []
  }
}

class MockOutput: OutputDestination {
  var lines = [String]()
  func writeLine(_ string: String) {
    lines.append(string)
  }
}

func mockWithTemporaryFile(
  dir _: AbsolutePath? = nil,
  prefix: String = "TemporaryFile",
  suffix _: String = "",
  deleteOnClose _: Bool = true, _
  body: (AbsolutePath) throws -> Void
) throws {
  let tmp = AbsolutePath("/tmp")
  let tmpFile = tmp.appending(component: prefix)
  try body(tmpFile)
}
