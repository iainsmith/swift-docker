import ArgumentParser
import Foundation
import TSCBasic

public struct TestCommand: ParsableCommand, DockerCommand {
  public static var configuration = CommandConfiguration(
    commandName: "test",
    abstract: "Test your swift package in a docker container.",
    discussion: """
    Defaults to testing the current directory using the official swift:latest docker image

    Examples:

    \(DocExamples.testCommand.indentLines(by: 2))
      swift docker test --image vapor/ubuntu/bionic

    Docker Labels:

    All docker images created from this command will have LABEL com.swiftdockercli.action=test so they can easily be deleted with `swift docker cleanup`
    """,
    shouldDisplay: true
  )

  @OptionGroup()
  var options: CLIOptions

  private(set) var output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  private(set) var shell: ShellProtocol.Type = ShellRunner.self

  public func run() throws {
    let labels = makeLabels(action: .buildForTesting)
    try removeVolumeIfNeeded()
    try createVolumeIfNeeded(labels: labels)

    output.writeLine("-> swift test - \(options.dockerBaseImage.fullName)")
    var cmd = "swift test"
    if !options.args.isEmpty { cmd += " \(options.args.joined(separator: " "))" }
    let testCommand = makeDockerRunCommand(cmd: cmd, labels: labels)
    try shell.runWithStreamingOutput(
      testCommand,
      controller: output,
      redirection: SquareBracketsLineRewriter.self,
      isVerbose: options.verbose
    )
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
