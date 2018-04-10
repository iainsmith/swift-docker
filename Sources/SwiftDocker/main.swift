import Commander
import Foundation
import SwiftDockerLib

Group() {
    let version = Option("swift",
                         default: "4.1",
                         flag: "s",
                         description: "The swift version to test against. e.g 4.0")
    // Ideally we could repreesent this as an optional.
    let image = Option("image",
                       default: "",
                       flag: "i",
                       description: "(Optional) The docker image to test against. e.g swiftdocker/swift:4.0")

    let writeDockerfile = Flag("write-dockerfile",
                               default: false,
                               flag: "w",
                               description: "Write the dockerfile to the current directory")

    /// swift docker test -s 4.1
    /// swift docker test -s 4.0
    /// swift docker test -s 4.0 -w
    /// swift docker test --swift 4.0 --write-dockerfile
    /// swift docker test --image swiftdocker/swift:latest
    $0.command("test",
               version, image, writeDockerfile,
               description: "Build and test the SPM package") { version, image, shouldWriteToLocalDir in
        try runDockerTests(version: version, image: image, writeDockerFile: shouldWriteToLocalDir)
    }
    /// swift docker test cleanup
    $0.command("cleanup", description: "Remove docker images created with swift docker") {
        try runDockerRemoveImages()
    }

    /// swift docker test write-dockerfile
    $0.command("write-dockerfile", version, description: "Write the default dockerfile to ./Dockerfile") { version in
        try writeDefaultDockerFile(version: version)
    }
}.run()
