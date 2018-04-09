import Commander
import ShellOut
import Foundation

/// Usage

/// swift test-linux
/// swift test-linux -v 4.1
/// swift test-linux -v 4.0
/// swift test-linux -v 4.0 -w
/// swift test-linux -i swiftdocker/swift:latest

/// swift test-linux test
/// swift test-linux cleanup
/// swift test-linux write-dockerfile

/// Docker Commands

extension FileManager {
    var workingDirectoryName: String {
        return self.currentDirectoryPath.components(separatedBy: "/").last!
    }
}

func writeDockerFile(_ dockerFile: String, fileManager: FileManager = .default) throws {
    let dockerFilePath = fileManager.currentDirectoryPath.appending(dockerPathComponent)
    try dockerFile.write(toFile: dockerFilePath, atomically: true, encoding: .utf8)
}

func runDockerTests(version: String, image: String, writeDockerFile shouldSaveFile: Bool) throws {
    let fileManager = FileManager.default

    let directoryName = fileManager.workingDirectoryName
    let dockerImage = image.isEmpty ? makeDefaultImage(forVersion: version) : image

    let minimalDockerfile = makeMinimalDockerFile(image: dockerImage, directory: directoryName)

    let currentPath = fileManager.currentDirectoryPath
    let dockerFilePath = currentPath.appending(dockerPathComponent)
    let existingDockerFile = fileManager.fileExists(atPath: dockerFilePath)
    if existingDockerFile == false {
        try writeDockerFile(minimalDockerfile)
    }

    let dockerTag = dockerImagePrefix + directoryName.replacingOccurrences(of: " ", with: "").lowercased()

    try shellOut(to: .dockerBuildCurrentDirectory(tag: dockerTag))
    let output = try shellOut(to: .dockerRun(tag: dockerTag, remove: true, command: "swift test"))
    print(output)

    if (existingDockerFile == false && shouldSaveFile == false) {
        try? fileManager.removeItem(atPath: dockerFilePath)
    }
}

Group() {
    let version = Option("swift", default: "4.1", flag: "s", description: "The swift version to test against. e.g 4.0")
    let image = Option("image", default: "", flag: "i", description: "(Optional) The docker image to test against. e.g swiftdocker/swift:4.0")
    let writeDockerfile = Flag("write-dockerfile", default: false, flag: "w", description: "Write the dockerfile to the current directory")

    let defaultCommand: CommandType = command(version, image, writeDockerfile) { version, image, shouldWriteToLocalDir in
        try runDockerTests(version: version, image: image, writeDockerFile: shouldWriteToLocalDir)
    }

    $0.addCommand("test", "Build and test the SPM package", defaultCommand)

    $0.command("cleanup", description: "Remove docker images with the prefix") {
        let startsWithTestPrefix = "^" + dockerImagePrefix
        try shellOut(to: .dockerRemoveImages(matchingPattern: startsWithTestPrefix))
    }

    $0.command("write-dockerfile", version, description: "Remove docker images with the prefix") { version in
        let currentDirectoryName = FileManager.default.workingDirectoryName
        let file = makeMinimalDockerFile(image: makeDefaultImage(forVersion: version), directory: currentDirectoryName)
        try writeDockerFile(file)
    }

    $0.noCommand = { string, group, parser in
        try defaultCommand.run(parser)
    }
}.run()
