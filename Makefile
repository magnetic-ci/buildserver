# See: http://clarkgrubb.com/makefile-style-guide
MAKEFLAGS         += --warn-undefined-variables
SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c
.DEFAULT_GOAL     := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Constants, these can be overwritten in your Makefile.local
VAMP_DOCKER_USER := magneticio
VAMP_DOCKER_REPO := buildserver
VAMP_DOCKER_TAG  := 0.1

# if Makefile.local exists, include it.
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

# Don't change these
docker_image := $(VAMP_DOCKER_USER)/$(VAMP_DOCKER_REPO):$(VAMP_DOCKER_TAG)
dependencies := docker

# Targets
.PHONY: all
all: check build


.PHONY: check
check:
	@echo "Checking dependencies:"
	$(foreach bin,$(dependencies),\
		$(if $(shell command -v $(bin)),\
			$(info Found in PATH: `$(bin)`),\
			$(error Missing from PATH: `$(bin)`)))


.PHONY: build
build: check
	docker build --tag $(docker_image) .


.PHONY: push
push: check build
	docker push $(docker_image)


.PHONY: run
run:
	docker run \
		--name "buildserver" \
		--hostname "buildserver" \
		--volume $(CURDIR)/build:/srv/build \
		--volume $(CURDIR)/cache:/srv/cache \
		--volume $(CURDIR)/src:/srv/src \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $(shell command -v docker):/usr/bin/docker \
		--interactive \
		--tty \
		--rm \
		$(docker_image) \
		/bin/bash

.PHONY: clean-all
clean-all:  clean-build clean-docker clean-src clean-src

.PHONY: clean-docker
clean-docker:
	docker rmi $(docker_image)

.PHONY: clean-cache
clean-cache:
	rm -rf $(CURDIR)/cache/*

.PHONY: clean-build
clean-build:
	rm -rf $(CURDIR)/build/*

.PHONY: clean-src
clean-src:
	rm -rf $(CURDIR)/src/*
