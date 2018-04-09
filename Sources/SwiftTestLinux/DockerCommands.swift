//
//  DockerCommands.swift
//  SwiftTestLinux
//
//  Created by iainsmith on 09/04/2018.
//

import ShellOut

extension ShellOutCommand {
    static func dockerBuildCurrentDirectory(tag: String) -> ShellOutCommand {
        return dockerBuild(tag: tag, dockerFile: ".")
    }

    static func dockerBuild(tag: String, dockerFile: String) -> ShellOutCommand {
        let cmd = "docker build -t \(tag) \(dockerFile)"
        return ShellOutCommand(string: cmd)
    }

    static func dockerRun(tag: String, remove: Bool, command: String) -> ShellOutCommand {
        let removeTag = remove ? "--rm" : ""
        let cmd = "docker run \(removeTag) \(tag) \(command)"
        return ShellOutCommand(string: cmd)
    }

    static func dockerRemoveImages(matchingPattern pattern: String) -> ShellOutCommand {
        let cmd = "docker images -a | grep \"\(pattern)\" | awk '{print $3}' | xargs docker rmi"
        return ShellOutCommand(string: cmd)
    }
}
