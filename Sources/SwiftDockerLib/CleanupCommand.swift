import ArgumentParser
import var TSCBasic.stdoutStream
import class TSCBasic.TerminalController

struct CleanupCommand: ParsableCommand {
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

  @Flag(name: .shortAndLong, help: "force remove outstanding images")
  var force: Bool

  @Flag(name: .shortAndLong, help: "Increase the level of output")
  var verbose: Bool

  // Internal for unit testing
  var terminal: OutputDestination = TerminalController(stream: stdoutStream) ?? stdoutStream
  var shell: ShellProtocol.Type = ShellRunner.self

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

  enum CodingKeys: String, CodingKey {
    case force
    case verbose
  }
}
