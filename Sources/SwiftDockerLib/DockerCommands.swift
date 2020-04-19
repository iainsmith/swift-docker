enum DockerCommands {
  static func dockerBuild(tag: String, dockerFilePath: String) -> String {
    let file = dockerFilePath == "." ? dockerFilePath : "--file \(dockerFilePath)"
    let dockerBuild = "docker build -t \(tag.lowercased()) \(file) ."
    return dockerBuild
  }

  static func dockerRun(tag: String, remove: Bool, command: String) -> String {
    let removeTag = remove ? "--rm" : ""
    let dockerRun = "docker run \(removeTag) \(tag.lowercased()) \(command)"
    return dockerRun
  }

  static func fetchImageIdentifiers(filter: String) -> String {
    "docker images --filter \(filter) --quiet"
  }

  static func deleteImages(identifiers: String, force: Bool) -> String {
    let forceFlag = force ? "--force" : ""
    return "docker rmi \(identifiers) \(forceFlag)"
  }
}
