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
        curl \
        git \
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
    && mv scala-${SCALA_VERSION} /usr/local/share/scala \
    && rm -rf /tmp/scala

# Install SBT
ENV SBT_VERSION=0.13.13
ENV SBT_URL=http://dl.bintray.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${SBT_VERSION}/sbt-launch.jar
RUN set -xe \
    && mkdir -p /usr/local/share/sbt/ \
    && curl --location --silent --output /usr/local/share/sbt/sbt-launch.jar "$SBT_URL" \
    && echo '#! /bin/bash' > /usr/local/bin/sbt \
    && echo 'SBT_OPTS="-Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled"' >> /usr/local/bin/sbt \
    && echo 'java $SBT_OPTS -jar /usr/local/share/sbt/sbt-launch.jar "$@"' >> /usr/local/bin/sbt \
    && chmod 0775 /usr/local/bin/sbt

# Install NodeJS
ENV NODE_VERSION=7.2.0
ENV NODE_URL=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
RUN set -xe \
    && mkdir -p /tmp/node \
    && cd /tmp/node \
    && curl --location --remote-name --silent --show-error "$NODE_URL" \
    && tar -zxf node-v${NODE_VERSION}-linux-x64.tar.gz \
    && mv node-v${NODE_VERSION}-linux-x64 /usr/local/share/node \
    && rm -rf /tmp/node

# Install Go
ENV GO_VERSION=1.7.4
ENV GO_URL=https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz
RUN set -xe \
    && curl --location --silent --show-error "$GO_URL" | tar -xzf - -C /usr/local


ENV PATH="/usr/local/share/scala/bin:/usr/local/share/node/bin:/usr/local/go/bin:$PATH"
