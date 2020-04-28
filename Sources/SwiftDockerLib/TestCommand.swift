import ArgumentParser
import Foundation
import TSCBasic

public struct TestCommand: ParsableCommand {
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

  @Flag(help: "Remove the docker .build folder")
  var clean: Bool

  @Option(parsing: .remaining, help: "swift test arguments such as --configuration/--parallel")
  var args: [String]

  private var outputDestinaton: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  private var shell: ShellProtocol.Type = ShellRunner.self

  public func run() throws {
    let projectLabel = FolderLabel.label(with: options.projectName)
    ifVerbosePrint("Checking for existing docker volume")

    let existingImages = try shell.run(
      "docker volume ls --quiet --filter label=\(projectLabel)",
      outputDestination: nil,
      isVerbose: options.verbose
    )

    let labels = """
    --label \(projectLabel) \
    --label \(ActionLabel.label(with: .buildForTesting))
    """

    if clean {
      try shell.run("docker volume rm \(options.dockerVolumeName)", outputDestination: nil, isVerbose: options.verbose)
    }

    let existingVolume = try existingImages.utf8OutputLines().contains(options.dockerVolumeName)
    if !existingVolume || clean {
      ifVerbosePrint("Creating new docker volume to cache .build folder")
      let result = try shell.run(
        """
        docker volume create \
        \(labels) \
        \(options.dockerVolumeName)
        """,
        outputDestination: nil,
        isVerbose: options.verbose
      )
      if case .terminated(code: 1) =  result.exitStatus {
        throw DockerError("Unable to create image")
      }
    }

    if seedBuildFolder {
      ifVerbosePrint("Copying .build folder to volume: \(options.dockerVolumeName)")
      let name = "swiftdockercli-seed"
      let folder = "/.build"
      try shell.runCleanExit("docker container create  --name \(name) --mount type=volume,source=\(options.dockerVolumeName),target=\(folder) \(options.dockerBaseImage.fullName)", outputDestination: nil, isVerbose: options.verbose)
      try shell.runCleanExit("docker cp \(options.buildFolderPath.pathString)/. \(name):\(folder)", outputDestination: nil, isVerbose: options.verbose)
      try shell.runCleanExit("docker rm \(name)", outputDestination: nil, isVerbose: options.verbose)
    }

    outputDestinaton.writeLine("-> swift test")

    var swiftTest = "swift test"
    if !args.isEmpty {
      swiftTest += " \(args.joined(separator: " "))"
    }

    let testCommand = """
    docker run --rm \
    --mount type=bind,source=\(options.absolutePath.pathString),target=/package \
    --mount type=volume,source=\(options.dockerVolumeName),target=/package/.build \
    --workdir /package \
    \(labels) \
    \(options.dockerBaseImage.fullName) \
    \(swiftTest)
    """

    let result = try shell.runWithStreamingOutput(
      testCommand,
      controller: outputDestinaton,
      redirection: SquareBracketsLineRewriter.self,
      isVerbose: options.verbose
    )

    switch result.exitStatus {
    case .terminated(code: 0), .signalled:
      break
    case let .terminated(exitCode):
      // The compiler likely crashed mid build/test command so leave an empty line
      outputDestinaton.writeLine("""

      \(swiftTest) returned a non zero exit code \(exitCode). To diagnose the cause
      you may want to re-run the command passing verbose to SwiftPM. e.g
      swift docker test --clean --args --verbose
      """)
      throw DockerError("Exit code \(exitCode)")
    }
  }

  public init() {}

  init(
    options: CLIOptions,
    seedBuildFolder: Bool = false,
    clean: Bool = false,
    args: [String] = [],
    output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self
  ) {
    self.options = options
    self.clean = clean
    self.seedBuildFolder = false
    outputDestinaton = output
    self.shell = shell
    self.args = args
  }

  enum CodingKeys: String, CodingKey {
    case options
    case seedBuildFolder
    case clean
    case args
  }

  func ifVerbosePrint(_ string: String) {
    if options.verbose {
      outputDestinaton.writeLine(string)
    }
  }
}
