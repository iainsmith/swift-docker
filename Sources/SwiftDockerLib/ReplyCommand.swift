import ArgumentParser
import Foundation
import TSCBasic

public struct ReplCommand: ParsableCommand, DockerCommand {
  public static var configuration = CommandConfiguration(
    commandName: "repl",
    abstract: "print the command to run the swift repl in a container.",
    discussion: """
    """,
    shouldDisplay: true
  )

  @OptionGroup()
  var options: CLIOptions
  var output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  var shell: ShellProtocol.Type = ShellRunner.self

  public func run() throws {
    let labels = makeLabels(action: .buildForTesting) // Do we want different labels
    try removeVolumeIfNeeded()
    try createVolumeIfNeeded(labels: labels)

    output.writeLine("-> swift - \(options.dockerBaseImage.fullName)")
    var cmd = "swift"

    if !options.args.isEmpty { cmd += " \(options.args.joined(separator: " "))" }
    let command = makeDockerRunCommand(cmd: cmd, labels: "", dockerFlags: "\(lldbPermissions) -it")
    // TODO: Figure out if we can start an interactive repl directly
    let message = """
    Run the below command to start the swift repl in the container.

      \(command)
    """
    if options.verbose {
      output.writeLine(message)
    } else {
      output.writeLine(command)
    }
  }

  public init() {}

  init(
    options: CLIOptions,
    output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self
  ) {
    self.options = options
    self.output = output
    self.shell = shell
  }

  enum CodingKeys: String, CodingKey {
    case options
  }
}
