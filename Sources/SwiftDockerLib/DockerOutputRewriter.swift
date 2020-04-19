import TSCBasic

protocol OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection
}

enum DockerOutputRewriter: OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection {
    .stream(stdout: { stdBytes in
      guard let string = String(bytes: stdBytes, encoding: .utf8) else { return }
      string.split { $0.isNewline }.forEach { (substring: Substring) in
        if substring.hasPrefix("Step ") {
          controller.write(substring.indent(by: 2))
          controller.endLine()
        }
        return
      }
    }, stderr: { errorBytes in
      guard let string = String(bytes: errorBytes, encoding: .utf8) else { return }
      string.split(separator: "\n").forEach { substring in
        controller.write(String(substring), inColor: .red)
        controller.endLine()
      }
    })
  }
}

enum VerboseOutputRedirection: OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection {
    .stream(stdout: { stdBytes in
      guard let string = String(bytes: stdBytes, encoding: .utf8) else { return }
      string.split { $0.isNewline }.forEach { (substring: Substring) in
        controller.write(substring.indent(by: 2))
        controller.endLine()
      }
    }, stderr: { errorBytes in
      guard let string = String(bytes: errorBytes, encoding: .utf8) else { return }
      string.split(separator: "\n").forEach { substring in
        controller.write(String(substring), inColor: .red)
        controller.endLine()
      }
    })
  }
}
