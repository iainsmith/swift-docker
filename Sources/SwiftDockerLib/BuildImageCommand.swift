import ArgumentParser
import Foundation
import TSCBasic

struct BuildImageCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "build-image",
    abstract: "Build a docker image for your swift package in a docker container.",
    discussion: """
    Examples:

      swift docker build --swift 5.2.2 --tag username/package:1.0
      swift docker build --image vapor/ubuntu:latst --tag username/package:1.0

    Docker Labels:

    All docker images created from this command will have LABEL com.swiftdockercli.action=build and will not be deleted by running `swift docker cleanup`
    """,
    shouldDisplay: true
  )

  @Option(name: .shortAndLong, help: "The tag for this image. e.g name/project:latest")
  var tag: String

  @OptionGroup()
  var options: CLIOptions

  func run() throws {
    // Docker build context is relative to the directory docker is being called from.
    // https://github.com/moby/moby/issues/4592
    // For testing we use the swift-tools-support InMemoryFileSystem which fatalErrors
    // on calls to changeCurrentWorkingDirectory in 0.1.1
    try localFileSystem.changeCurrentWorkingDirectory(to: options.absolutePath)
    try BuildCommandRunner(tag: tag, options: options).run(action: .build)
  }
}

struct BuildCommandRunner {
  private let options: CLIOptions
  private let filesystem: FileSystem
  private let outputDestinaton: OutputDestination
  private let shell: ShellProtocol.Type
  private let withTemporaryFileClosure: TemporaryFileFunction
  private let tag: String

  init(
    tag: String,
    options: CLIOptions,
    fileSystem: FileSystem = localFileSystem,
    output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self,
    withTemporaryFile: TemporaryFileFunction? = nil
  ) {
    self.tag = tag
    self.options = options
    self.shell = shell
    filesystem = fileSystem
    outputDestinaton = output
    withTemporaryFileClosure = withTemporaryFile ?? { dir, prefix, suffix, delete, body in
      try TSCBasic.withTemporaryFile(dir: dir, prefix: prefix, suffix: suffix, deleteOnClose: delete) { tempfile in try body(tempfile.path) }
    }
  }

  func withTemporaryFile(
    dir: AbsolutePath? = nil,
    prefix: String = "TemporaryFile",
    suffix: String = "",
    deleteOnClose: Bool = true, _
    body: (AbsolutePath) throws -> Void
  ) throws {
    try withTemporaryFileClosure(dir, prefix, suffix, deleteOnClose, body)
  }

  func run(action: ActionLabel) throws {
    _ = try withTemporaryFile(prefix: "Dockerfile") { (file) -> Void in
      let dockerfileBody = Dockerfile.makeMinimalDockerFile(
        image: options.dockerBaseImage.fullName,
        directory: options.projectName,
        action: action
      )

      try filesystem.writeFileContents(file, bytes: ByteString(encodingAsUTF8: dockerfileBody), atomically: true)
      if options.verbose { outputDestinaton.writeLine("Created temporary Dockerfile at \(file.pathString)") }

      let buildCommand = DockerCommandsLegacy.dockerBuild(tag: tag, dockerFilePath: file.pathString)
      outputDestinaton.writeLine("-> docker build")
      let buildOutput = try shell.runWithStreamingOutput(
        buildCommand,
        controller: outputDestinaton,
        redirection: DockerOutputRewriter.self,
        isVerbose: options.verbose
      )

      if buildOutput.exitStatus == .terminated(code: 1) { throw DockerError.failedToRunCommand(buildCommand) }
    }
  }
}
