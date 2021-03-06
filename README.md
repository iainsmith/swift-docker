# swift-docker

A command line tool for building, testing & running your swift package in a docker container.

<img src="https://s3.eu-west-2.amazonaws.com/iainpublicgifs/swift-docker-small.gif" width="500">

* [Quick start](#quick-start-for-macOS)
* [Features](#Features)
* [Installation](#Install-swift-docker)
* [Usage](#Usage)
* [Vapor](#Vapor)
* [Docker Labels](#docker-labels)

## Quick start for macOS

```sh
brew install iainsmith/formulae/swift-docker # Install swift docker
git clone https://github.com/jpsim/Yams.git # Clone an example package
cd Yams && swift test # Run the tests on your machine
swift docker test # Run the tests in a container
swift docker test --swift 5.1 # Check if the tests pass on swift 5.1
swift docker write-dockerfile # Write a ./Dockerfile to the repo
```

## Features

* [x] Test swift packages in one command `swift docker test`
* [x] Use custom images - `swift docker test --image vapor/swift:latest`
* [x] `swift docker build/test/run` commands mirror `swift build/test/run`
* [x] Run your vapor application in a container - `swift docker vapor`
* [x] Cached builds using docker volumes
* [x] Use a mix of docker volumes & bind mounts for fast, small builds.
* [x] Uses the swift docker image that matches the Package.swift manifest.
* [x] Quickly free up space - `swift docker cleanup`
* [x] Create a dockerfile for your project
* [x] Quickly print a command to run the swift repl in the container - `swift docker repl`
* [ ] Create a .dockerignore file to avoid adding .git directory to the image
* [ ] Support multistage slim builds
* [ ] Log output to a file
* [ ] cmake build for running on Windows

## Install swift-docker

Install with Homebrew
```sh
brew install iainsmith/formulae/swift-docker
```
<details>
<summary>
Install from source
</summary>
<pre>
> git clone https://github.com/iainsmith/swift-docker-cli.git
> cd swift-docker
> swift build -c release --disable-sandbox
# copy the binary to somewhere in your path.
> cp ./.build/release/swift-docker ~/bin
</pre>
</details>
</br>

<details>
<summary>
And install docker if you don't have it already
</summary>

* Download the [Docker Mac App](https://www.docker.com/docker-mac).
* Or alternatively install via homebrew `brew cask install docker`
</details>

## Usage

```bash
OVERVIEW: A simple workflow for building & testing swift packages with docker

Run swift docker <subcommand> --help for subcommand details
Reference - Offical docker images: https://hub.docker.com/_/swift

Examples:

swift docker test
swift docker build -- --configuration release
swift docker run your-executable --flag1
swift docker vapor

USAGE: swift-docker <subcommand>

OPTIONS:
-h, --help              Show help information.

SUBCOMMANDS:
build                   Build your swift package in a docker container.
test                    Test your swift package in a docker container.
run                     Run your swift package in a docker container.
vapor                   Run your vapor web application in a container.
build-image             Build a docker image for your swift package.
repl                    print the command to run the swift repl in a container.
cleanup                 Remove temporary docker images.
write-dockerfile        Write a dockerfile to disk.
```

## Vapor

Run `swift docker vapor` to run your vapor application in a docker container. This is significantly faster than workflows that require you
to build a docker image as we bind the local directory into the container, and cache the build folder.

* You can pass custom arguments to your application by running `swift docker vapor -- arg1 --flag1`.
* Currently the environment is set to production & the port is set to 8080.
* The default docker image is `swift:latest`. You can use a custom image with `swift docker vapor --image vapor/swift:latest`

## Docker labels

Each docker image created by `swift-docker` is tagged with two labels.

```
LABEL com.swiftdockercli.action="test/build"
LABEL com.swiftdockercli.folder="your-project-name"
```

Running `docker volume ls --filter label=com.swiftdockercli.action=test` will list volumes created by swift-docker test.

## Contributing

If you have suggestions for new commands, features or bug fixes. Please raise an issue or open a PR.

If you find this tool useful in your workflow let me know on twitter [@_iains](https://twitter.com/_iains)

## Credits

swift-docker is built on top of

* [swift-tools-support-core](https://github.com/apple/swift-tools-support-core)
* [swift-argument-parser](https://github.com/apple/swift-argument-parser)
