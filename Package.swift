// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDockerCLI",
    products: [
        .executable(name: "swift-docker", targets: ["SwiftDocker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iainsmith/ShellOut", from: "2.2.0"),
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.1"),
    ],
    targets: [
        .target(
            name: "SwiftDocker",
            dependencies: ["SwiftDockerLib"]),
        .target(
            name: "SwiftDockerLib",
            dependencies: ["ShellOut", "Commander", "Rainbow"]),
        .testTarget(
            name: "SwiftDockerLibTests",
            dependencies: ["SwiftDockerLib"]
        ),
    ]
)
