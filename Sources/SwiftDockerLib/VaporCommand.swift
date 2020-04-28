import ArgumentParser
import Foundation
import TSCBasic

public struct VaporCommand: ParsableCommand, DockerCommand {
  public static var configuration = CommandConfiguration(
    commandName: "vapor",
    abstract: "Run your vapor web application in a container.",
    discussion: """
    Pass custom arguments using the -- separator
      e.g swift docker vapor -- arg1 --flag1
    """,
    shouldDisplay: true
  )

  @OptionGroup()
  var options: CLIOptions
  var output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  var shell: ShellProtocol.Type = ShellRunner.self

  public mutating func validate() throws {
    if options.swift == nil && options.image == nil {
      options.swift = "latest" // Prefer latest over swift-tools-version for vapor
    }
  }

  public func run() throws {
    let labels = makeLabels(action: .buildForTesting) // Do we want different labels
    try removeVolumeIfNeeded()
    try createVolumeIfNeeded(labels: labels)

    output.writeLine("-> swift run serve - \(options.dockerBaseImage.fullName)")
    var cmd = "swift run --enable-test-discovery Run serve --hostname 0.0.0.0 --env production"

    // TODO: let people override the hostname and env
    if !options.args.isEmpty { cmd += " \(options.args.joined(separator: " "))" }
    let testCommand = makeDockerRunCommand(cmd: cmd, labels: labels, dockerFlags: "-p 8080:8080")
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
