## Docker Labels

[Docker Guide](https://docs.docker.com/config/labels-custom-metadata/)

our prefix is com.swiftdockercli

LABEL com.swiftdockercli.action="test"/"build"
LABEL com.swiftdockercli.folder="name-of-your-project"
* "com.swiftdockercli.action"= - images created from the test command
* "com.swiftdockercli.build" - images created from the build command

LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"

Identifying test images created with `swift-docker` = `docker images --filter "com.swiftdockercli.action=bar"`

## Docker Tags

https://docs.docker.com/engine/reference/commandline/tag/

## Ideas

* `swift docker test -s 4.1`
* `swift docker test -s 4.0`
* `swift docker test --configuration release`
* `swift docker test --swift 4.0 --configuration release`
* `swift docker test --image swiftdocker/swift:latest`
* `swift docker build --tag my-tag`
* `swift docker run ./build/hello --interactive`
* `swift docker run --daemon/--background`
* `swift docker test --log docker.log`
