# Vamp build server

Fedora 25 based Docker image containing all the necessary tooling to build all components of Vamp. Available at [the Docker Hub](https://hub.docker.com/r/magneticio/buildserver/).

The purpose of this machine is for people to be able to build all necessary components of Vamp by only having Docker and `make` installed on their machine.


## Entrypoint

The entrypoint has two main purposes:
1. Execute command passed to build server as either root or specific user
2. Perform specific tasks, such as `push` or `pull` items from the stash volume

For details see the [source code](files/usr/local/bin/buildserver-entrypoint).


## Boilerplate `Makefile`

The following `Makefile` can be used as a starting point for other projects. 
The default target will pull the latest image, and then launch the container with necessary settings, and then execute commands through its entrypoint. 

An easy way to setup the build commands is to define them as another target, and then calling them from the default target, as this will then run the specified target inside the buildserver.

By default everything is ran as root inside the container, if this is undesirable the following environment variables should be set, and the entrypoint will setup a local user inside the container, and continue execution of the commands as that user instead. This is useful when you don't want the output files to be owned by root, for example.

- `BUILD_UID=$(shell id -u)`
- `BUILD_GID=$(shell id -g)`


```Makefile
# See: http://clarkgrubb.com/makefile-style-guide
SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c
.DEFAULT_GOAL     := default
.DELETE_ON_ERROR:
.SUFFIXES:

# Constants, these can be overwritten in your Makefile.local
BUILD_SERVER := magneticio/buildserver

# if Makefile.local exists, include it.
ifneq ("$(wildcard Makefile.local)", "")
    include Makefile.local
endif

# Don't change these
TARGET  := $(CURDIR)/bootstrap/target
VERSION := $(shell git describe --tags)

# Targets
.PHONY: all
all: default

# Using our buildserver which contains all the necessary dependencies
.PHONY: default
default:
    docker pull $(BUILD_SERVER)
    docker run \
        --name buildserver \
        --interactive \
        --tty \
        --rm \
        --volume $(CURDIR):/srv/src \
        --workdir=/srv/src \
        --env BUILD_UID=$(shell id -u) \
        --env BUILD_GID=$(shell id -g) \
        $(BUILD_SERVER) \
            make build

.PHONY: build
build:
    # Normal build steps...

```

**Note:** Make expects hard tabs in the `Makefile`. Take care to ensure your editor is not replacing these with soft tabs, as that can break the functionality of make.
