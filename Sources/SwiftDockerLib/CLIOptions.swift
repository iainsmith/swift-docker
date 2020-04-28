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

  @Flag(help: "Remove the docker .build folder")
  var clean: Bool

  @Flag(help: "Copy the .build folder from your machine to the container")
  var seedBuildFolder: Bool

  @Option(parsing: .remaining, help: "swift test arguments such as --configuration/--parallel")
  var args: [String]

  var absolutePath: AbsolutePath {
    try! AbsolutePath(validating: url.path)
  }

  var dockerBaseImage: DockerTag {
    DockerTag(version: swift, image: image)!
  }

  var projectName: String {
    absolutePath.basename
  }

  var dockerVolumeName: String {
    "swiftdockercli-\(projectName)"
  }

  var defaultDockerfilePath: AbsolutePath {
    absolutePath.appending(component: "Dockerfile")
  }

  var buildFolderPath: AbsolutePath {
    absolutePath.appending(component: ".build")
  }

  public init() {}

  public init(swift: String = "latest", image: String? = nil, path: String = ".", verbose: Bool,
              clean: Bool = false, args: [String] = [], seedBuildFolder: Bool = false) {
    self.swift = swift
    self.image = image
    let expanded = NSString(string: path).expandingTildeInPath
    self.url = URL(fileURLWithPath: expanded)
    self.verbose = verbose
    self.clean = clean
    self.args = args
    self.seedBuildFolder = seedBuildFolder
  }

  public func validate() throws {
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
