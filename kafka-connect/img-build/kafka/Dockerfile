FROM azul/zulu-openjdk-alpine:11.0.5-jre

# Set the version, home directory, and MD5 hash.
# MD5 hash taken from http://kafka.apache.org/downloads.html for this version of Kafka
#
ENV KAFKA_VERSION=2.4.0 \
    SCALA_VERSION=2.12 \
    KAFKA_HOME=/kafka \
    SHA512HASH="53B52F86EA56C9FAC62046524F03F75665A089EA2DAE554AEFE3A3D2694F2DA88B5BA8725D8BE55F198BA80695443559ED9DE7C0B2A2817F7A6141008FF79F49"
ENV KAFKA_URL_PATH=kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

# Create a user and home directory for Kafka
#
USER root

RUN set -eux; \
    \
    apk add --no-cache --upgrade iproute2 curl bash; \
    adduser --uid 1001 -D -s /sbin/nologin kafka --home $KAFKA_HOME; \
    mkdir $KAFKA_HOME/data; \
    mkdir $KAFKA_HOME/logs; \
    \
# Change ownership and switch user
    chown -R kafka: $KAFKA_HOME; \
    chgrp -R kafka $KAFKA_HOME

# Download Kafka
#
RUN set -eux; \
    \
    curl -fSL -o /tmp/kafka.tgz \
      $(curl --stderr /dev/null \
          https://www.apache.org/dyn/closer.cgi\?as_json\=1 \
          | sed -rn 's/.*"preferred":.*"(.*)"/\1/p' \
       )$KAFKA_URL_PATH \
      || curl -fSL -o /tmp/kafka.tgz \
      https://archive.apache.org/dist/$KAFKA_URL_PATH; \
# Verify the contents and then install ...
    tar -xzf /tmp/kafka.tgz -C $KAFKA_HOME --strip-components 1; \
    rm -f /tmp/kafka.tgz; \
# Remove unnecessary files
    rm $KAFKA_HOME/libs/*-sources.jar*; \
    rm $KAFKA_HOME/libs/*-javadoc.jar*; \
    rm $KAFKA_HOME/libs/*-scaladoc.jar*

COPY ./log4j.properties $KAFKA_HOME/config/log4j.properties
RUN mkdir $KAFKA_HOME/config.orig; \
    mv $KAFKA_HOME/config/* $KAFKA_HOME/config.orig; \
# Allow random UID to use Kafka
    chmod -R g+w,o+w $KAFKA_HOME

USER kafka

# Set the working directory to the Kafka home directory
WORKDIR $KAFKA_HOME

# Expose the ports and set up volumes for the data and logs directories
#
EXPOSE 9092
VOLUME ["/kafka/data","/kafka/logs","/kafka/config"]

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/bin/bash", "/docker-entrypoint.sh"]
CMD ["start"]
