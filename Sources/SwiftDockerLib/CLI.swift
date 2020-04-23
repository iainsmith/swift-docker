import ArgumentParser
import var TSCBasic.localFileSystem

public struct SwiftDockerCLI: ParsableCommand {
  public static var configuration: CommandConfiguration = CommandConfiguration(
    commandName: "swift-docker",
    abstract: "A simple workflow for building & testing swift packages with docker",
    discussion: """
    Run swift docker <subcommand> --help for subcommand details
    Reference - Offiical docker images: https://hub.docker.com/_/swift

    Examples:

    \(DocExamples.testCommand.indentLines(by: 2))
      swift docker build --swift 5.2.2 --tag username/package:1.0
      swift docker write-dockerfile --swift 5.2.2
      swift docker cleanup # Remove all images created with swift docker test
    """,
    shouldDisplay: true,
    subcommands: [TestCommand.self, BuildCommand.self, CleanupCommand.self, WriteDockerfileCommand.self]
  )

  public init() {}
}
