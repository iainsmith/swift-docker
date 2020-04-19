import ArgumentParser
import var TSCBasic.stdoutStream
import class TSCBasic.TerminalController

struct CleanupCommand: ParsableCommand {
  @Flag(name: .shortAndLong)
  var verbose: Bool

  @Flag(name: .shortAndLong)
  var force: Bool

  static let configuration = CommandConfiguration(
    commandName: "cleanup",
    abstract: "Remove temporary docker images.",
    discussion: """
    All swift-docker DOCKERFILEs are tagged with the following labels

      LABEL \(Dockerfile.ActionLabel.label)=\(Dockerfile.ActionLabel.buildForTesting.rawValue)/\(Dockerfile.ActionLabel.build.rawValue)
      LABEL \(Dockerfile.FolderLabel.label)=name-of-folder

    You can list all test images created using

      docker images --filter "label=\(Dockerfile.filter(for: .buildForTesting))"
    """
  )

  func run() throws {
    try CleanupCommandRunner(verbose: verbose, force: force).run()
  }
}

struct CleanupCommandRunner {
  private let terminal: OutputDestination
  private let shell: ShellProtocol.Type
  private let verbose: Bool
  private let force: Bool

  init(
    verbose: Bool,
    force: Bool = false,
    terminal: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream,
    shell: ShellProtocol.Type = ShellRunner.self
  ) {
    self.verbose = verbose
    self.force = force
    self.terminal = terminal
    self.shell = shell
  }

  func run() throws {
    let fetchTestImagesCommand = DockerCommands.fetchImageIdentifiers(filter: Dockerfile.filter(for: .buildForTesting))
    let fetchImageResult = try shell.run(fetchTestImagesCommand, outputDestination: nil, isVerbose: verbose)
    if fetchImageResult.exitStatus != .terminated(code: 0) {
      throw DockerError.failedToRunCommand(fetchTestImagesCommand)
    }

    let imageIdentifiers = try fetchImageResult.utf8Output().split { $0.isNewline }
    if imageIdentifiers.isEmpty {
      terminal.writeLine("No images to delete")
      return
    }

    let deleteCommand = DockerCommands.deleteImages(identifiers: imageIdentifiers.joined(separator: " "), force: force)
    let deleteResult = try shell.run(deleteCommand, outputDestination: nil, isVerbose: verbose)
    if deleteResult.exitStatus != .terminated(code: 0) {
      terminal.writeLine(try deleteResult.utf8stderrOutput())
    }
    if verbose {
      terminal.writeLine(try deleteResult.utf8Output())
    } else {
      terminal.writeLine("Deleted \(imageIdentifiers.count) images")
    }
  }
}
