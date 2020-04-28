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

  @Flag(help: "Copy the .build folder from your machine to the container")
  var seedBuildFolder: Bool

  @Option(parsing: .remaining, help: "swift test arguments such as --configuration/--parallel")
  var args: [String]

  private(set) var output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  private(set) var shell: ShellProtocol.Type = ShellRunner.self

  public func run() throws {
    let labels = makeLabels(action: .buildForTesting)
    ifVerbosePrint("Checking for existing docker volume")
    try removeVolumeIfNeeded()
    try createVolumeIfNeeded(labels: labels)
    if seedBuildFolder { try copyBuildFolderToVolume() }

    output.writeLine("-> swift test - \(options.dockerBaseImage.fullName)")
    var swiftTest = "swift test"
    if !args.isEmpty { swiftTest += " \(args.joined(separator: " "))" }
    let testCommand = makeDockerRunCommand(cmd: "swift test", labels: labels)
    try shell.runWithStreamingOutput(
      testCommand,
      controller: output,
      redirection: SquareBracketsLineRewriter.self,
      isVerbose: options.verbose
    )
  }

  public init() {}

  init(options: CLIOptions, seedBuildFolder: Bool = false, clean: Bool = false, args: [String] = [],
    output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self
  ) {
    self.options = options
    self.seedBuildFolder = false
    self.output = output
    self.shell = shell
    self.args = args
  }

  enum CodingKeys: String, CodingKey {
    case options
    case seedBuildFolder
    case args
  }
}
