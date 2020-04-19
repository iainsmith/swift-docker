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

  public func run() throws {
    // Docker build context is relative to the directory docker is being called from.
    // https://github.com/moby/moby/issues/4592
    // For testing we use the swift-tools-support InMemoryFileSystem which fatalErrors
    // on calls to changeCurrentWorkingDirectory in 0.1.1
    try localFileSystem.changeCurrentWorkingDirectory(to: options.absolutePath)
    try TestCommandRunner(options: options).run()
  }

  public init() {}

  public init(options: CLIOptions) {
    self.options = options
  }
}

/// You must run this command from the options.absolutePath directory.
struct TestCommandRunner {
  private var options: CLIOptions
  private let filesystem: FileSystem
  private let outputDestinaton: OutputDestination
  private let shell: ShellProtocol.Type
  private let withTemporaryFileClosure: TemporaryFileFunction
  private let computeGitSHA: () -> String

  func run() throws {
    let uniqueHash = computeGitSHA() // TODO:
    let tagName = "swift-docker/\(options.projectName.lowercased()):\(uniqueHash)"

    try BuildCommandRunner(
      tag: tagName, options: options, fileSystem: filesystem,
      output: outputDestinaton, shell: shell,
      withTemporaryFile: withTemporaryFileClosure
    ).run(action: .buildForTesting)

    let testCommand = DockerCommands.dockerRun(tag: tagName, remove: true, command: "swift test")
    outputDestinaton.writeLine("-> swift test")
    try shell.runWithStreamingOutput(
      testCommand,
      controller: outputDestinaton,
      redirection: SquareBracketsLineRewriter.self,
      isVerbose: options.verbose
    )
  }

  init(options: CLIOptions) {
    self.init(
      options: options,
      fileSystem: localFileSystem,
      output: TerminalController(stream: stdoutStream) ?? stdoutStream,
      shell: ShellRunner.self
    )
  }

  init(
    options: CLIOptions,
    fileSystem: FileSystem = localFileSystem,
    output: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self,
    withTemporaryFile: TemporaryFileFunction? = nil,
    computeGitSHA: (() -> String)? = nil
  ) {
    self.options = options
    filesystem = fileSystem
    outputDestinaton = output
    self.shell = shell
    withTemporaryFileClosure = withTemporaryFile ?? { dir, prefix, suffix, delete, body in
      try TSCBasic.withTemporaryFile(dir: dir, prefix: prefix, suffix: suffix, deleteOnClose: delete) { tempfile in try body(tempfile.path) }
    }
    self.computeGitSHA = computeGitSHA ?? { String(NSUUID().uuidString.prefix(6)) }
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
}
