public struct DockerError: Error {
  public let message: String

  init(_ message: String) {
    self.message = message
  }

  static func failedToRunCommand(_ cmd: String) -> DockerError {
    DockerError("failed to run \(cmd)")
  }
}
