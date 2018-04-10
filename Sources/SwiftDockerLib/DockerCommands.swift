/// NOTE
///
/// Shell out should only be called from this file so that it's easy to swap out if we can't
/// get streaming output working.

import Foundation
import ShellOut

func runAndLog(_ cmd: ShellOutCommand, prefix: String) throws {
    printTitle("\(prefix): \(cmd.string)")
    let output = try shellOut(to: cmd)
    printBody(output)
}

// MARK: Run & Delete operations

func cleanup(path: String, fileManager: FileManager, silent: Bool = false) {
    if silent == false { printTitle("Removing temporary Dockerfile") }
    try? fileManager.removeItem(atPath: path)
}

func runDockerTests(image: DockerImage, writeDockerFile shouldSaveFile: Bool) throws {
    let fileManager = FileManager.default
    let tempDockerFilePath = NSTemporaryDirectory().appending(tempDockerFilePathComponent)

    do {
        cleanup(path: tempDockerFilePath, fileManager: fileManager, silent: true)

        let directoryName = fileManager.currentDirectoryName
        let minimalDockerfile = makeMinimalDockerFile(image: image.imageName, directory: directoryName)

        printTitle("Creating temporary Dockerfile at \(tempDockerFilePath)")
        printBody(minimalDockerfile)
        try minimalDockerfile.write(toFile: tempDockerFilePath, atomically: true, encoding: .utf8)

        let dockerTag = makeDockerTag(forDirectoryName: directoryName, version: image.imageName)

        try runDockerBuild(tag: dockerTag, dockerFilePath: tempDockerFilePath)
        try runDockerSwiftTest(tag: dockerTag, remove: true)

        cleanup(path: tempDockerFilePath, fileManager: fileManager)

        if shouldSaveFile {
            try minimalDockerfile.write(toFile: defaultDockerFilePath, atomically: true, encoding: .utf8)
        }
    } catch {
        cleanup(path: tempDockerFilePath, fileManager: fileManager, silent: true)
        printError(error.localizedDescription)
    }
}

public func runDockerTests(version: String, image: String, writeDockerFile shouldSaveFile: Bool) throws {
    guard let image = DockerImage(version: version, image: image) else { fatalError() }
    try runDockerTests(image: image, writeDockerFile: shouldSaveFile)
}

// MARK: Shellout wrappers

public func runDockerRemoveImages() throws {
    let startsWithTestPrefix = "^" + dockerImagePrefix
    let remove = ShellOutCommand.dockerRemoveImages(matchingPattern: startsWithTestPrefix)
    try runAndLog(remove, prefix: "Removing images")
}

public func writeDefaultDockerFile(version: String) throws {
    let file = makeMinimalDockerFile(image: makeDefaultImage(forVersion: version), directory: FileManager.default.currentDirectoryName)
    try file.write(toFile: defaultDockerFilePath, atomically: true, encoding: .utf8)
}

func runDockerSwiftTest(tag: String, remove: Bool) throws {
    let testCMD = ShellOutCommand.dockerRun(tag: tag, remove: remove, command: "swift test")
    try runAndLog(testCMD, prefix: "Running swift test")
}

func runDockerBuild(tag: String, dockerFilePath: String) throws {
    let buildCmd = ShellOutCommand.dockerBuild(tag: tag, dockerFile: dockerFilePath)
    try runAndLog(buildCmd, prefix: "Building docker image")
}
