import Foundation

let dockerImagePrefix = "spm-test-"

let tempDockerFilePathComponent = "/.temp-dockerfile"
fileprivate let defaultDockerPathComponent = "/Dockerfile"

func makeDefaultImage(forVersion version: String) -> String {
    return "swiftdocker/swift:\(version)"
}

func makeMinimalDockerFile(image: String, directory directoryName: String) -> String {
    let directory = directoryName.replacingOccurrences(of: " ", with: "\\ ").lowercased()

    return """
    FROM \(image)
    COPY . /\(directory)
    WORKDIR /\(directory)
    RUN swift build
    """
}

func makeDockerTag(forDirectoryName directory: String, version: String) -> String {
    let tagEscapedDirectory = directory.replacingOccurrences(of: " ", with: "").lowercased()
    let dockerTag = dockerImagePrefix + tagEscapedDirectory + "-" + version
    return dockerTag
}

let defaultDockerFilePath = FileManager.default.currentDirectoryPath.appending(defaultDockerPathComponent)

extension FileManager {
    var currentDirectoryName: String {
        return currentDirectoryPath.components(separatedBy: "/").last!
    }
}
