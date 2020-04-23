import Foundation
import TSCBasic

enum SquareBracketsLineRewriter: OutputRewriter {
  static func make(controller: TerminalController) -> TSCBasic.Process.OutputRedirection {
    .stream(stdout: { stdBytes in
      var needsEndLine = false
      guard let string = String(bytes: stdBytes, encoding: .utf8) else { return }
      string.eachLine { substring in
        let isInlineTotal = substring.hasPrefix("[")
        if isInlineTotal {
          controller.clearLine()
          needsEndLine = true
        } else if needsEndLine {
          controller.endLine()
          needsEndLine = false
        }

        controller.write(substring.indent(by: 2))

        if !isInlineTotal {
          controller.endLine()
        }
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
