FROM azul/zulu-openjdk-alpine:11.0.5-jre

# Set the version, home directory, and MD5 hash.
# MD5 hash taken from http://kafka.apache.org/downloads.html for this version of Kafka
#
ENV KAFKA_VERSION=2.6.0 \
    SCALA_VERSION=2.13 \
    KAFKA_HOME=/kafka \
    SHA512HASH="d884e4df7d85b4fff54ca9cd987811c58506ad7871b9ed7114bbafa6fee2e79f43d04c550eea471f508b08ea34b4316ea1e529996066fd9b93fcf912f41f6165"
ENV KAFKA_URL_PATH=kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

# Create a user and home directory for Kafka
#
USER root

RUN set -eux; \
    \
    apk add --no-cache --upgrade iproute2 curl bash; \
    addgroup -g 1001 -S kafka; \
    adduser -G kafka -u 1001 -s /bin/bash -h $KAFKA_HOME -S -D kafka; \
    \
    chmod 755 $KAFKA_HOME; \
    mkdir $KAFKA_HOME/data; \
    mkdir $KAFKA_HOME/logs; \
    \
# Change ownership and switch user
    chown -R kafka $KAFKA_HOME; \
    chgrp -R kafka $KAFKA_HOME; \
# Download Kafka
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
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
