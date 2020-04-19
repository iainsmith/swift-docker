import ArgumentParser
import struct TSCBasic.ByteString
import protocol TSCBasic.FileSystem
import var TSCBasic.localFileSystem
import var TSCBasic.stdoutStream
import class TSCBasic.TerminalController

struct WriteDockerfileCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "write-dockerfile",
    abstract: "Write a dockerfile to disk.",
    discussion: """
      swift docker write-dockerfile # Save to ./Dockerfile using swift:latest
      swift docker write-dockerfile --swift 5.1 --path Dockerfile.test # Save to ./Dockerfile.test using swift:5.1
    """
  )

  @OptionGroup()
  var options: CLIOptions

  func run() throws {
    try WriteDockerfileCommandRunner(options: self.options).run()
  }
}

struct WriteDockerfileCommandRunner {
  private var options: CLIOptions
  private let filesystem: FileSystem
  private let outputDestinaton: OutputDestination

  func run() throws {
    let dockerfileBody = Dockerfile.makeMinimalDockerFile(
      image: options.baseImage.fullName,
      directory: options.projectName,
      action: .build
    )

    try filesystem.writeFileContents(
      options.defaultDockerfilePath,
      bytes: ByteString(encodingAsUTF8: dockerfileBody),
      atomically: true
    )

    outputDestinaton.writeLine("Saved dockerfile to \(options.defaultDockerfilePath.prettyPath())")
    if options.verbose { outputDestinaton.writeLine(dockerfileBody) }
  }

  init(
    options: CLIOptions,
    filesystem: FileSystem = localFileSystem,
    outputDestinaton: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  ) {
    self.options = options
    self.filesystem = filesystem
    self.outputDestinaton = outputDestinaton
  }
}
