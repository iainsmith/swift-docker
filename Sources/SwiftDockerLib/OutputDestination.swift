import class TSCBasic.TerminalController
import class TSCBasic.ThreadSafeOutputByteStream

protocol OutputDestination {
  func writeLine(_ string: String)
}

extension TerminalController: OutputDestination {
  func writeLine(_ string: String) {
    write(string)
    endLine()
  }
}

extension ThreadSafeOutputByteStream: OutputDestination {
  func writeLine(_ string: String) {
    write(string)
  }
}
