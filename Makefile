MAKEFLAGS         += --warn-undefined-variables
SHELL             := bash
.SHELLFLAGS       := -eu -o pipefail -c
.DEFAULT_GOAL     := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Constants, these can be overwritten in your Makefile.local
VAMP_DOCKER_USER := magneticio
VAMP_DOCKER_REPO := vamp-buildserver
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
all: check build push


.PHONY: check
check:
	@echo "Checing buikld dependencies:"
	$(foreach bin,$(dependencies),\
		$(if $(shell command -v $(bin)),\
			$(info Found in PATH: `$(bin)`),\
			$(error Missing from PATH: `$(bin)`)))


.PHONY: build
build: check
	docker build --tag $(docker_image) .


.PHONY: push
push: check
	docker push $(docker_image)


.PHONY: run
run:
	docker run \
		--name "vamp-buildserver" \
		--hostname "vamp-buildserver" \
		--volume $(CURDIR)/src:/usr/local/src \
		--interactive \
		--tty \
		--rm \
		$(docker_image) \
		/bin/bash

.PHONY: clean
clean:
	docker rmi $(docker_image)