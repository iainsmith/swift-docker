// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-docker-cli",
  platforms: [.macOS(.v10_14)],
  products: [
    .executable(name: "swift-docker", targets: ["SwiftDocker"]),
    .library(name: "SwiftDocker", targets: ["SwiftDocker"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-tools-support-core",
      .upToNextMinor(from: "0.1.1")
    ),
    .package(
      url: "https://github.com/apple/swift-argument-parser",
      .upToNextMinor(from: "0.0.5")
    ),
  ],
  targets: [
    .target(
      name: "SwiftDocker",
      dependencies: ["SwiftDockerLib"]
    ),
    .target(
      name: "SwiftDockerLib",
      dependencies: [
        .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .testTarget(
      name: "SwiftDockerLibTests",
      dependencies: ["SwiftDockerLib"]
    ),
  ]
)
