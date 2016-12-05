FROM alpine:3.4

# Base layer for our image
RUN set -xe \
    && printf 'http://dl-cdn.alpinelinux.org/alpine/v3.4/%s\n' main community > /etc/apk/repositories \
    && apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      git \
      libgcc \
      libstdc++ \
      openjdk8-jre

# Install Scala
ENV SCALA_VERSION=2.12.0
ENV SCALA_URL=http://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz
RUN set -xe \
    && mkdir -p /tmp/scala \
    && cd /tmp/scala \
    && curl --location --remote-name --silent --show-error "$SCALA_URL" \
    && tar -zxf scala-${SCALA_VERSION}.tgz \
    && mv scala-${SCALA_VERSION}/* /usr/local/ \
    && rm -rf /tmp/*

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
ENV NODE_SRC_URL=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz
ENV NODE_SRC_SHA256=https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc
ENV GYP_DEFINES="linux_use_gold_flags=0"
RUN set -xe \
    && apk add --no-cache --virtual .build-node \
      g++ \
      gcc \
      gnupg \
      linux-headers \
      make \
      paxctl \
      python \
    && mkdir -p  /tmp/node \
    && cd /tmp/node \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
      9554F04D7259F04124DE6B476D5A82AC7E37093B \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    && curl --location --remote-name --silent --show-error ${NODE_SRC_URL} \
    && curl --location --remote-name --silent --show-error ${NODE_SRC_SHA256} \
    && gpg --verify SHASUMS256.txt.asc \
    && grep node-v${NODE_VERSION}.tar.gz SHASUMS256.txt.asc | sha256sum -c - \
    && tar -zxf node-v${NODE_VERSION}.tar.gz \
    && cd node-v${NODE_VERSION} \
    && ./configure \
      --prefix=/usr/local \
      --fully-static \
    && export NPROC=$(grep -c ^processor /proc/cpuinfo || echo 1) \
    && make -j${NPROC} -C out mksnapshot BUILDTYPE=Release \
    && paxctl -cm out/Release/mksnapshot \
    && make -j${NPROC} \
    && make install \
    && paxctl -cm /usr/local/bin/node \
    && apk del .build-node \
    && rm -rf /tmp/*


