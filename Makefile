# See: http://clarkgrubb.com/makefile-style-guide
MAKEFLAGS         += --warn-undefined-variables
SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c
.DEFAULT_GOAL     := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Constants, these can be overwritten in your Makefile.local
DOCKER_USER := magneticio
DOCKER_REPO := buildserver
DOCKER_TAG  := 0.4

# if Makefile.local exists, include it.
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

# Don't change these
docker_image := $(DOCKER_USER)/$(DOCKER_REPO):$(DOCKER_TAG)
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

	$(CURDIR)/tools/build-info.sh


.PHONY: build
build: check
	docker build --tag $(docker_image) .

.PHONY: push
push: check
	docker push $(docker_image)

.PHONY: push-latest
push-latest: check push
	docker tag $(docker_image) $(DOCKER_USER)/$(DOCKER_REPO):latest
	docker push $(DOCKER_USER)/$(DOCKER_REPO):latest

.PHONY: run
run:
	docker run \
		--name "buildserver" \
		--hostname "buildserver" \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $(shell command -v docker):/usr/bin/docker \
		--interactive \
		--tty \
		--rm \
		--volume $(CURDIR)/srv:/srv \
		$(docker_image) \
		/bin/bash

.PHONY: run-user
run-user:
	docker run \
		--name "buildserver" \
		--hostname "buildserver" \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $(shell command -v docker):/usr/bin/docker \
		--env BUILD_UID=$(shell id -u) \
		--env BUILD_GID=$(shell id -g) \
		--interactive \
		--tty \
		--rm \
		--volume $(CURDIR)/srv:/srv \
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
