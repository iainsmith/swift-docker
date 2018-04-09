// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTestLinux",
    products: [
        .executable(name: "swift-test-linux", targets: ["SwiftTestLinux"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.1.0"),
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.1")
    ],
    targets: [
        .target(
            name: "SwiftTestLinux",
            dependencies: ["ShellOut", "Commander"]),
        .testTarget(
            name: "Example")
    ]
)
