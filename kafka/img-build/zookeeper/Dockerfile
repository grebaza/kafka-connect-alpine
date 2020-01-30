FROM azul/zulu-openjdk-alpine:11.0.5-jre

#
# Set the version, home directory
#
ENV ZK_VERSION=3.5.6 \
    ZK_HOME=/zookeeper
ENV ZK_URL_PATH=zookeeper/zookeeper-$ZK_VERSION/apache-zookeeper-$ZK_VERSION-bin.tar.gz


# Create a user and home directory for Zookeeper
#
USER root
RUN set -eux; \
    \
    apk add --no-cache iproute2 curl bash; \
    adduser --uid 1001 -D -s /sbin/nologin zookeeper --home $ZK_HOME; \
    \
# Change ownership and switch user
    chown -R zookeeper $ZK_HOME; \
    chgrp -R zookeeper $ZK_HOME

USER zookeeper

RUN set -eux; \
    \
    mkdir $ZK_HOME/data; \
    mkdir $ZK_HOME/txns; \
    mkdir $ZK_HOME/logs; \
# Download and install Zookeeper
    curl -fSL -o /tmp/zookeeper.tar.gz \
        https://archive.apache.org/dist/$ZK_URL_PATH; \
# Verify the contents and then install ...
    tar -xzf /tmp/zookeeper.tar.gz -C $ZK_HOME --strip-components 1; \
    rm -f /tmp/zookeeper.tar.gz; \
# Remove unnecessary files
    rm -rf $ZK_HOME/docs; \
# Allow random UID to use Zookeeper
    chmod -R g+w,o+w $ZK_HOME

# Set the working directory to the Zookeeper home directory
WORKDIR $ZK_HOME


# Customize the Zookeeper and Log4J configuration files
#
COPY ./zoo.cfg $ZK_HOME/conf/zoo.cfg
RUN set -eux; \
    \
    sed -i -r \
        -e "s|(\\$\\{zookeeper.log.dir\\})|$ZK_HOME/logs|g" \
        -e "s|(\\$\\{zookeeper.tracelog.dir\\})|$ZK_HOME/logs|g" \
        -e "s|(\\$\\{zookeeper.log.file\\})|zookeeper.log|g" \
        -e "s|(\\$\\{zookeeper.tracelog.file\\})|zookeeper_trace.log|g" \
        -e "s|(\[myid\:\%X\{myid\}\]\s?)||g" \
        -e 's|#(log4j.appender.ROLLINGFILE.MaxBackupIndex.*)|\1|g' \
        $ZK_HOME/conf/log4j.properties; \
    mkdir $ZK_HOME/conf.orig && mv $ZK_HOME/conf/* $ZK_HOME/conf.orig


# Expose the ports and set up volumes for the data, transaction log,
# and configuration
#
EXPOSE 2181 2888 3888
VOLUME ["/zookeeper/data","/zookeeper/txns","/zookeeper/conf"]

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]

