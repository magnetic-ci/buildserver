FROM fedora:25

# Base layer for our image
RUN set -xe \
    && echo "deltarpm=0" >> /etc/dnf/dnf.conf \
    && dnf --assumeyes update \
    && dnf clean all

# FIXME: This install nearly 500MB of packages, need to select only the
#        necessary packages needed for building.
# RUN set -xe \
#     && dnf --assumeyes group install development-tools \
#     && dnf clean all

RUN set -xe \
    && dnf --assumeyes install \
        bzip2 \
        curl \
        git \
        gzip \
        tar \
    && dnf clean all

# Install Scala
ENV SCALA_VERSION=2.12.0
ENV SCALA_URL=http://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz
RUN set -xe \
    && dnf --assumeyes install java-1.8.0-openjdk \
    && dnf clean all \
    && mkdir -p /tmp/scala \
    && cd /tmp/scala \
    && curl --location --remote-name --silent --show-error "$SCALA_URL" \
    && tar -zxf scala-${SCALA_VERSION}.tgz \
    && mv scala-${SCALA_VERSION} /usr/local/scala \
    && rm -rf /tmp/scala

# Install SBT
ENV SBT_VERSION=0.13.13
ENV SBT_URL=http://dl.bintray.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${SBT_VERSION}/sbt-launch.jar
ADD scripts/sbt /usr/local/bin/sbt
RUN set -xe \
    && chmod 0775 /usr/local/bin/sbt \
    && curl --output /usr/local/bin/sbt-launch.jar --location --silent --show-error "$SBT_URL"

# Install NVM + NodeJS + NPM
ENV NVM_VERSION=0.32.1
ENV NVM_USE_VERSION=v7.2.1
ENV NVM_URL=https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh
ENV NVM_DIR=/usr/local/nvm
RUN set -xe \
    && curl --output - "$NVM_URL" | bash \
    && test -s "${NVM_DIR}/nvm.sh" && . "${NVM_DIR}/nvm.sh" \
    && nvm install "$NVM_USE_VERSION" \
    && nvm use "$NVM_USE_VERSION"

# Install Go
ENV GO_VERSION=1.7.4
ENV GO_URL=https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz
ENV GOPATH=/usr/local/src/go
RUN set -xe \
    && curl --silent --show-error "$GO_URL" | tar -xzf - -C /usr/local \
    && mkdir -p /usr/local/src/go


ENV PATH="/usr/local/scala/bin:/usr/local/go/bin:$PATH"
