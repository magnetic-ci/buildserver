# Vamp build server

Fedora 25 based Docker image containing all the necessary tooling to build all components of Vamp.

Too customize the build, you can add a `Makefile.local` with your own settings.
For example:
```Makefile
VAMP_DOCKER_USER := iamtew
VAMP_DOCKER_REPO := vamp-buildserver
VAMP_DOCKER_TAG  := dev
```
