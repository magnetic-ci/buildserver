FROM fedora:25

# Base layer for our image
RUN set -xe \
    && echo "deltarpm=0" >> /etc/dnf/dnf.conf \
    && dnf makecache fast \
    && dnf --assumeyes update \
    \
    && dnf --assumeyes install \
        bzip2 \
        curl \
        git \
        gzip \
        tar \
    && dnf clean all

ENV DIR_BUILD=/srv/build
ENV DIR_CACHE=/srv/cache
ENV DIR_SRC=/srv/src
RUN set -xe \
    && mkdir -p "$DIR_BUILD" \
    && mkdir -p "$DIR_CACHE" \
    && mkdir -p "$DIR_SRC"

# Install Scala
ENV SCALA_VERSION=2.12.1
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
ENV PATH="/usr/local/scala/bin:$PATH"

# Install SBT
ENV SBT_VERSION=0.13.13
ENV SBT_URL=http://dl.bintray.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${SBT_VERSION}/sbt-launch.jar
ADD scripts/sbt /usr/local/bin/sbt
RUN set -xe \
    && chmod 0775 /usr/local/bin/sbt \
    && curl --output /usr/local/bin/sbt-launch.jar --location --silent --show-error "$SBT_URL"

# Install NVM + NodeJS + NPM
ENV NVM_VERSION=0.33.0
ENV NVM_USE_VERSION=v7.5.0
ENV NVM_URL=https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh
ENV NVM_DIR=/usr/local/nvm
RUN set -xe \
    && curl --output - "$NVM_URL" | bash \
    && test -s "${NVM_DIR}/nvm.sh" && . "${NVM_DIR}/nvm.sh" \
    && nvm install "$NVM_USE_VERSION" \
    && nvm use "$NVM_USE_VERSION"
ENV PATH="${NVM_DIR}/versions/node/${NVM_USE_VERSION}/bin/:$PATH"
ENV PATH="./node_modules/.bin:$PATH"


# Install Go
ENV GO_VERSION=1.7.4
ENV GO_URL=https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz
ENV GOPATH="${DIR_SRC}/go"
RUN set -xe \
    && curl --silent --show-error "$GO_URL" | tar -xzf - -C /usr/local \
    && mkdir -p "$GOPATH"
ENV PATH="/usr/local/go/bin:${GOPATH}/bin:$PATH"

# Install Leiningen
ENV LEIN_ROOT=yes
ENV LEIN_HOME=/srv/cache/lein
ENV LEIN_URL=https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
RUN set -xe \
    && curl --output /usr/local/bin/lein "$LEIN_URL" \
    && chmod 0755 /usr/local/bin/lein

ENV GOSU_VERSION=1.10
RUN set -xe \
    && curl --location --silent --show-error --output /usr/local/bin/gosu \
      https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 \
    && chmod 0755 /usr/local/bin/gosu


ADD files/ /

ADD scripts/buildserver-entrypoint /usr/local/bin/buildserver-entrypoint

ADD buildinfo /etc/motd

ENTRYPOINT ["/usr/local/bin/buildserver-entrypoint"]

