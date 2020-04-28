import Foundation
import class TSCBasic.Process
import struct TSCBasic.ProcessResult
import class TSCBasic.TerminalController

protocol ShellProtocol {
  @discardableResult
  static func runWithStreamingOutput(
    _ cmd: String,
    controller: OutputDestination,
    redirection: OutputRewriter.Type,
    isVerbose: Bool
  ) throws -> ProcessResult

  @discardableResult
  static func run(_ cmd: String, outputDestination: OutputDestination?, isVerbose: Bool) throws -> ProcessResult

  @discardableResult
  static func runCleanExit(_ cmd: String, outputDestination: OutputDestination?, isVerbose: Bool) throws -> ProcessResult
}

enum ShellRunner: ShellProtocol {
  @discardableResult
  static func runWithStreamingOutput(
    _ cmd: String,
    controller: OutputDestination,
    redirection: OutputRewriter.Type,
    isVerbose: Bool
  ) throws -> ProcessResult {
    if let controller = controller as? TerminalController {
      if isVerbose {
        return try runStreamingOutput(cmd, controller: controller,
                                      redirection: VerboseOutputRedirection.self, isVerbose: isVerbose)
      }
      return try runStreamingOutput(cmd, controller: controller, redirection: redirection, isVerbose: isVerbose)
    } else {
      return try run(cmd, outputDestination: controller, isVerbose: isVerbose)
    }
  }

  @discardableResult
  static func runStreamingOutput(
    _ cmd: String,
    controller: TerminalController,
    redirection: OutputRewriter.Type,
    isVerbose: Bool
  ) throws -> ProcessResult {
    let cmds = cmd.split(separator: " ").map { String($0) }
    let process = Process(
      arguments: cmds,
      outputRedirection: redirection.make(controller: controller),
      verbose: isVerbose,
      startNewProcessGroup: true
    )

    try process.launch()
    return try process.waitUntilExitOrInterupt(didInterupt: { _ in
      controller.clearLine()
      controller.writeLine("Shutting down container")
    })
  }

  @discardableResult
  static func run(_ cmd: String, outputDestination: OutputDestination?, isVerbose: Bool) throws -> ProcessResult {
    let cmds = cmd.split(separator: " ").map { String($0) }
    let process = Process(arguments: cmds, verbose: isVerbose, startNewProcessGroup: true)
    try process.launch()

    let result = try process.waitUntilExit()
    if outputDestination != nil {
      let output: String = (try? result.utf8Output()) ?? ""
      outputDestination?.writeLine(output)
    }

    return result
  }
}

extension ShellProtocol {
  static func runCleanExit(_ cmd: String, outputDestination: OutputDestination?, isVerbose: Bool) throws -> ProcessResult {
    let result = try run(cmd, outputDestination: outputDestination, isVerbose: isVerbose)
    if case .terminated(code: 1) = result.exitStatus {
      throw DockerError("\(cmd) failed")
    }
    return result
  }
}
