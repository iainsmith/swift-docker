import ArgumentParser
import Foundation
import TSCBasic

public struct CLIOptions: ParsableArguments {
  @Option(name: .shortAndLong, default: "latest", help: "swift tag found at https://hub.docker.com/_/swift \n  e.g latest, 5.2, 5.2.2-slim")
  var swift: String

  @Option(name: .shortAndLong, help: "a custom docker image to use as the base image\n  e.g vapor/ubuntu:bionic")
  var image: String?

  @Option(name: [.customShort("p"), .customLong("path")], default: URL(fileURLWithPath: "."), help: "a path to the swift package if not using the current directory")
  var url: URL

  @Flag(name: .shortAndLong, help: "Increase the level of output")
  var verbose: Bool

  @Flag(name: .customLong("skip-validation"), help: .hidden)
  var skipValidation: Bool

  var absolutePath: AbsolutePath {
    try! AbsolutePath(validating: url.path)
  }

  var baseImage: DockerTag {
    DockerTag(version: swift, image: image)!
  }

  var projectName: String {
    absolutePath.basename
  }

  var defaultDockerfilePath: AbsolutePath {
    absolutePath.appending(component: "Dockerfile")
  }

  public init() {}

  public func validate() throws {
    if skipValidation { return }

    if swift != "latest", image != nil {
      throw ValidationError("--swift and --image are exclusive options")
    }

    if url.pathComponents.contains("DerivedData") {
      throw ValidationError("Running from Xcode without an explicit --path")
    }

    let packageSwift = url.appendingPathComponent("Package").appendingPathExtension("swift")
    if !localFileSystem.exists(packageSwift) {
      throw ValidationError("No Package.swift file found in \(url.path)")
    }
  }
}
