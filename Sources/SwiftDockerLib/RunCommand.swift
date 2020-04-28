import ArgumentParser
import Foundation
import TSCBasic

struct RunCommand: ParsableCommand, DockerCommand {
  static let configuration = CommandConfiguration(
    commandName: "run",
    abstract: "Run your swift package in a docker container.",
    discussion: """
    Examples:

      swift docker run --swift 5.2.2 --args my-binary arg1 arg2

    Docker Labels:

    All docker containers created from this command will have LABEL com.swiftdockercli.action=build and will not be deleted by running `swift docker cleanup`
    """,
    shouldDisplay: true
  )

  @OptionGroup()
  var options: CLIOptions

  private(set) var output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  private(set) var shell: ShellProtocol.Type = ShellRunner.self

  init() {}

  init(
    options: CLIOptions,
    output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self
  ) {
    self.options = options
    self.shell = shell
    self.output = output
  }

  func run() throws {
    let labels = makeLabels(action: .buildForTesting)
    try removeVolumeIfNeeded()
    try createVolumeIfNeeded(labels: labels)

    output.writeLine("-> swift run - \(options.dockerBaseImage.fullName)")
    var cmd = "swift run"
    if !options.args.isEmpty { cmd += " \(options.args.joined(separator: " "))" }
    let command = makeDockerRunCommand(cmd: cmd, labels: labels)
    try shell.runWithStreamingOutput(
      command,
      controller: output,
      redirection: SquareBracketsLineRewriter.self,
      isVerbose: options.verbose
    )
  }

  enum CodingKeys: String, CodingKey {
    case options
  }
}
