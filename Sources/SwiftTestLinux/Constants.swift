//
//  Constants.swift
//  SwiftTestLinux
//
//  Created by iainsmith on 09/04/2018.
//

import Foundation

let dockerImagePrefix = "spm-test-"

let dockerPathComponent = "/Dockerfile"

func makeDefaultImage(forVersion version: String) -> String {
    return "swiftdocker/swift:\(version)"
}

func makeMinimalDockerFile(image: String, directory directoryName: String) -> String {
    let directory = directoryName.replacingOccurrences(of: " ", with: "\\ ").lowercased()

    return  """
    FROM \(image)
    COPY . /\(directory)
    WORKDIR /\(directory)
    RUN swift build
    """
}
