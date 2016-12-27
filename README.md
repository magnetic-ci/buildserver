# Vamp build server

Fedora 25 based Docker image containing all the necessary tooling to build all components of Vamp. Available at [the Docker Hub](https://hub.docker.com/r/magneticio/buildserver/).

The Makefile contains several targets. If you just want to use build the components of Vamp you can do `make run` to sping up a container on your machine. For more details see the Makefile.

Following directories are setup to store various artifacts (these are also mapped to this repositories empty subdirectories in the `run` target):

* /srv/build
* /srv/cache
* /srv/src

## Customize
Too customize the build, you can add a `Makefile.local` with your own settings.
For example:
```Makefile
VAMP_DOCKER_USER := iamtew
VAMP_DOCKER_REPO := buildserver
VAMP_DOCKER_TAG  := dev
```
