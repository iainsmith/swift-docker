import TSCBasic

protocol OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection
}

enum DockerOutputRewriter: OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection {
    .stream(stdout: { stdBytes in
      guard let string = String(bytes: stdBytes, encoding: .utf8) else { return }
      string.eachLine { line in
        if line.hasPrefix("Step ") {
          controller.write(line.indent(by: 2))
          controller.endLine()
        }
        return
      }
    }, stderr: { errorBytes in
      guard let string = String(bytes: errorBytes, encoding: .utf8) else { return }
      string.eachLine {
        controller.write($0, inColor: .red)
        controller.endLine()
      }
    })
  }
}

enum VerboseOutputRedirection: OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection {
    .stream(stdout: { stdBytes in
      guard let string = String(bytes: stdBytes, encoding: .utf8) else { return }
      string.eachLine {
        controller.write($0.indent(by: 2))
        controller.endLine()
      }
    }, stderr: { errorBytes in
      guard let string = String(bytes: errorBytes, encoding: .utf8) else { return }
      string.eachLine {
        controller.write($0, inColor: .red)
        controller.endLine()
      }
    })
  }
}

extension String {
  func eachLine(body: (String) throws -> Void) rethrows {
    try split { $0.isNewline }.forEach { try body(String($0)) }
  }
}
