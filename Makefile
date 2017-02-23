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

# if Makefile.local exists, include it.
ifneq ("$(wildcard Makefile.local)", "")
	include Makefile.local
endif

# Don't change these
docker_image := $(DOCKER_USER)/$(DOCKER_REPO)
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

	$(CURDIR)/tools/buildinfo.sh

.PHONY: build
build: check
	@echo "Building container: $(docker_image):$$(<tag)"
	@if [[ $$(<tag) = "katana" ]] ; then \
		docker build --tag $(docker_image):katana . ;\
	else \
		docker build --tag $(docker_image):$$(<version) . ;\
		docker tag $(docker_image):$$(<version) $(docker_image):$$(<tag) ;\
	fi

.PHONY: push
push: check
	@echo "Pushing container: $(docker_image):$$(<tag)"
	@if [[ $$(<tag) = "katana" ]] ; then \
		docker push $(docker_image):katana ;\
	else \
		docker push $(docker_image):$$(<version) ;\
		docker push $(docker_image):$$(<tag) ;\
	fi

.PHONY: run
run: check
	docker run \
		--name "buildserver" \
		--hostname "buildserver" \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $(shell command -v docker):/usr/bin/docker \
		--interactive \
		--tty \
		--rm \
		--volume $(CURDIR)/srv:/srv \
		$(docker_image):$$(<tag) \
		/bin/bash

.PHONY: run-user
run-user: check
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
		$(docker_image):$$(<tag) \
		/bin/bash

.PHONY: clean
clean:
	rm -f $(CURDIR)/buildinfo $(CURDIR)/version $(CURDIR)/tag

.PHONY: clean-docker
clean-docker:
	docker rmi $(docker_image):$$(<tag)
