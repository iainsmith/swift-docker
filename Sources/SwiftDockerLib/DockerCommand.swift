protocol DockerCommand {
  var options: CLIOptions { get }
  var shell: ShellProtocol.Type { get }
  var output: OutputDestination { get }
}

extension DockerCommand {
  var lldbPermissions: String {
    "--cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt apparmor=unconfined"
  }

  func makeLabels(action: ActionLabel) -> String {
    let projectLabel = FolderLabel.label(with: options.projectName)
    return """
    --label \(projectLabel) \
    --label \(ActionLabel.label(with: action))
    """
  }

  func removeVolumeIfNeeded() throws {
    if options.clean {
      try shell.run("docker volume rm \(options.dockerVolumeName)", outputDestination: nil, isVerbose: options.verbose)
    }
  }

  func createVolumeIfNeeded(labels: String) throws {
    ifVerbosePrint("Checking for existing docker volume")
    let projectLabel = FolderLabel.label(with: options.projectName)

    let existingImages = try shell.run(
      "docker volume ls --quiet --filter label=\(projectLabel)",
      outputDestination: nil,
      isVerbose: options.verbose
    )

    let existingVolume = try existingImages.utf8OutputLines().contains(options.dockerVolumeName)
    if !existingVolume || options.clean {
      ifVerbosePrint("Creating new docker volume to cache .build folder")
      let result = try shell.run(
        """
        docker volume create \
        \(labels) \
        \(options.dockerVolumeName)
        """,
        outputDestination: nil,
        isVerbose: options.verbose
      )
      if case .terminated(code: 1) = result.exitStatus {
        throw DockerError("Unable to create image")
      }
    }

    if options.seedBuildFolder { try copyBuildFolderToVolume() }
  }

  func copyBuildFolderToVolume() throws {
    ifVerbosePrint("Copying .build folder to volume: \(options.dockerVolumeName)")
    let name = "swiftdockercli-seed"
    let folder = "/.build"
    try shell.runCleanExit("docker container create  --name \(name) --mount type=volume,source=\(options.dockerVolumeName),target=\(folder) \(options.dockerBaseImage.fullName)", outputDestination: nil, isVerbose: options.verbose)
    try shell.runCleanExit("docker cp \(options.buildFolderPath.pathString)/. \(name):\(folder)", outputDestination: nil, isVerbose: options.verbose)
    try shell.runCleanExit("docker rm \(name)", outputDestination: nil, isVerbose: options.verbose)
  }

  func makeDockerRunCommand(cmd: String, labels: String, dockerFlags: String? = nil) -> String {
    let dockerImage = options.dockerBaseImage.fullName
    var dockerCommandAndFlags = """
    docker run --rm \
    --mount type=bind,source=\(options.absolutePath.pathString),target=/package \
    --mount type=volume,source=\(options.dockerVolumeName),target=/package/.build \
    --workdir /package
    """

    dockerFlags.map { dockerCommandAndFlags += " \($0)" }

    let labelsAndCommand = """
    \(labels) \
    \(dockerImage) \
    \(cmd)
    """

    return dockerCommandAndFlags + " " + labelsAndCommand
  }

  func ifVerbosePrint(_ string: String) {
    if options.verbose {
      output.writeLine(string)
    }
  }
}
