# swift-docker

A command line tool for building & testing your swift package in a docker container.

<img src="https://s3.eu-west-2.amazonaws.com/iainpublicgifs/swift-docker-small.gif" width="500">

* [Quick start](#quick-start-for-macOS)
* [Features](#Features)
* [Installation](#Install-swift-docker)
* [Usage](#Usage)
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
* [x] Quickly free up space - `swift docker cleanup`
* [x] `swift docker build/test/run` mirror `swift build/test/run`
* [x] Create a dockerfile for your project
* [x] Cached builds using docker volumes
* [x] Use a mix of docker volumes & bind mounts for fast, small builds.
* [x] Uses the swift docker image that matches the Package.swift manifest.
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
OVERVIEW: Build and test your swift packages in docker

Simple commands for working with the official swift docker images
https://hub.docker.com/_/swift

examples:

swift docker test #test the package in the current directory
swift docker test --swift 5.1 # test your package against swift:5.1
swift docker test --path ~/code/my-package # test a package in a directory
swift docker write-dockerfile --swift 5.2.2-slim
swift docker cleanup # Remove all images created with swift docker test

USAGE: swift-docker <subcommand>

OPTIONS:
-h, --help              Show help information.

SUBCOMMANDS:
test                    Test your swift package in a docker container.
cleanup                 Remove temporary docker images.
write-dockerfile        Write a dockerfile to disk.
```

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
