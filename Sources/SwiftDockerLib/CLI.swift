import ArgumentParser
import var TSCBasic.localFileSystem

public struct SwiftDockerCLI: ParsableCommand {
  public static var configuration: CommandConfiguration = CommandConfiguration(
    commandName: "swift-docker",
    abstract: "A simple workflow for building & testing swift packages with docker",
    discussion: """
    Run swift docker <subcommand> --help for subcommand details
    Reference - Offical docker images: https://hub.docker.com/_/swift

    Examples:

      swift docker test
      swift docker build -- --configuration release
      swift docker run your-executable --flag1
      swift docker vapor
    """,
    shouldDisplay: true,
    subcommands: [BuildCommand.self, TestCommand.self, RunCommand.self, VaporCommand.self, BuildImageCommand.self, ReplCommand.self, CleanupCommand.self, WriteDockerfileCommand.self]
  )

  public init() {}
}
