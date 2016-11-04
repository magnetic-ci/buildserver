FROM alpine:3.4

RUN set -xe \
    && printf 'http://dl-cdn.alpinelinux.org/alpine/v3.4/%s\n' main community > /etc/apk/repositories \
    && apk add --no-cache \
            bash \
            curl \
            file \
            git \
            openjdk8-jre


ENV SCALA_VERSION=2.12.0
ENV SCALA_URL=http://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz
RUN set -xe \
    && curl --location --silent "$SCALA_URL" | tar -xzf - -C /usr/local/share \
    && mv /usr/local/share/scala-${SCALA_VERSION} /usr/local/share/scala


ENV SBT_VERSION=0.13.13
ENV SBT_URL=http://dl.bintray.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${SBT_VERSION}/sbt-launch.jar
RUN set -xe \
    && mkdir -p /root/.sbt/launchers/${SBT_VERSION} \
    && curl --location --silent --output /root/.sbt/launchers/${SBT_VERSION}/sbt-launch.jar "$SBT_URL"


ENV NODE_VERSION=7.0.0
ENV NODE_URL=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
RUN set -xe \
    && curl --location --silent "$NODE_URL" | tar -xzf - -C /usr/local/share \
    && mv /usr/local/share/node-v${NODE_VERSION}-linux-x64 /usr/local/share/node


ENV GOLANG_VERSION=1.7.3
ENV GOLANG_SRC_URL=https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz
RUN set -ex \
    && apk add --no-cache \
      gcc \
      musl-dev \
      openssl \
    && curl --location --silent "$GOLANG_SRC_URL" | tar -xzf - -C /usr/local/src


ENV PATH=/usr/local/share/node/bin:/usr/local/share/scala/bin:$PATH
