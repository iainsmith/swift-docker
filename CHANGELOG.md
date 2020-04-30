# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- `swift docker test` defaults to using the swift-tools-version specified in Package.swift

### Added
- `swift docker repl` - Print the command to start the swift repl in a container
- `swift docker vapor` - Run your vapor application in a container
- `swift docker run` - mirrors swift run command
- `swift docker build` - mirrors swift build
- `swift docker build-image` builds a docker image of your package
- Extract docker command logic to `DockerCommand` protocol for code reuse across commands.

## [0.3.0] - 2020-04-24

### Added

- `swift docker test --seed-build-foler` - Copy the current .build folder to the container volume
- `swift docker test --clean` - Delete and re create the .build folder in the container volume

### Changed
- swift docker test no longer builds an image to run the tests. Instead it:
  - uses a bind mount to sync the source code between the host and the container
  - create/re-uses a docker volume for the .build folder

### Removed
- Documentation for docker build
