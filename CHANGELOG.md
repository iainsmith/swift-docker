# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
