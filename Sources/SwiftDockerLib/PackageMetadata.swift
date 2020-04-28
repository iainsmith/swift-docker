import Foundation
import TSCBasic

enum PackageMetadata {
  static func toolsVersion(for path: AbsolutePath, isVerbose: Bool) throws -> String {
    let previousDirectory = localFileSystem.currentWorkingDirectory
    try localFileSystem.changeCurrentWorkingDirectory(to: path)
    let cmd = "swift package dump-package"
    let data = try ShellRunner.run(cmd, outputDestination: nil, isVerbose: isVerbose).utf8Output()
    guard let json = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!, options: .allowFragments) as? [String: Any] else {
      throw DockerError("Unable to run \(cmd) in \(path.prettyPath())")
    }
    guard let toolsDictionary = json["toolsVersion", default: [:]] as? [String: Any],
      let version = toolsDictionary["_version"] as? String else {
        throw DockerError("No toolsVersion Key")
    }

    if let previousDirectory = previousDirectory {
      try localFileSystem.changeCurrentWorkingDirectory(to: previousDirectory)
    }
    // SPM seems to always specify 3 digit version such as 5.0.0
    // where as the docker images use 2 digits e.g 5.0
    let imageVersion = String(version.dropLast(2))
    if imageVersion.count != 3 { throw DockerError("Invalid assumptions about SPM versioning") }
    return imageVersion
  }
}
