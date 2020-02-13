# Stage: connect-base
ARG KAFKA_IMAGE
FROM $KAFKA_IMAGE as connect_base

EXPOSE 8083
VOLUME ["/kafka/data","/kafka/logs","/kafka/config"]

COPY docker-entrypoint.sh /
COPY log4j.properties $KAFKA_HOME/config/log4j.properties
COPY docker-maven-download.sh /usr/local/bin/docker-maven-download

#
# Set up the plugins directory ...
#
ENV KAFKA_CONNECT_PLUGINS_DIR=$KAFKA_HOME/connect \
    CONNECT_PLUGIN_PATH=$KAFKA_CONNECT_PLUGINS_DIR \
    MAVEN_DEP_DESTINATION=$KAFKA_HOME/libs \
    CONFLUENT_VERSION=5.1.2 \
    AVRO_VERSION=1.8.2 \
    AVRO_JACKSON_VERSION=1.9.13

RUN mkdir $KAFKA_CONNECT_PLUGINS_DIR;

#
# The `docker-entrypoint.sh` script will automatically discover the child directories
# within the $KAFKA_CONNECT_PLUGINS_DIR directory (e.g., `/kafka/connect`), and place
# all of the files in those child directories onto the Java classpath.
#
# The general recommendation is to create a separate child directory for each connector
# (e.g., "debezium-connector-mysql"), and to place that connector's JAR files
# and other resource files in that child directory.
#
# However, use a single directory for connectors when those connectors share dependencies.
# This will prevent the classes in the shared dependencies from appearing in multiple JARs
# on the classpath, which results in arcane NoSuchMethodError exceptions.
#
RUN set -eux; \
    \
    docker-maven-download confluent kafka-connect-avro-converter \
        "$CONFLUENT_VERSION" b6b8507bdc518d8c3d7d4a62b6140977; \
    docker-maven-download confluent kafka-avro-serializer \
        "$CONFLUENT_VERSION" 464857f51204412996e2bb81d67a94e8; \
    docker-maven-download confluent kafka-schema-registry-client \
        "$CONFLUENT_VERSION" e3078fa805dd793e9d97d2bf395d037a; \
    docker-maven-download confluent common-config \
        "$CONFLUENT_VERSION" 4ee0fb996cea8691196c4187876b388b; \
    docker-maven-download confluent common-utils \
        "$CONFLUENT_VERSION" 7aef21c3824f218252b8f2383c71840f; \
    docker-maven-download central org/codehaus/jackson jackson-core-asl \
        "$AVRO_JACKSON_VERSION" 319c49a4304e3fa9fe3cd8dcfc009d37; \
    docker-maven-download central org/codehaus/jackson jackson-mapper-asl \
        "$AVRO_JACKSON_VERSION" 1750f9c339352fc4b728d61b57171613; \
    docker-maven-download central org/apache/avro avro \
        "$AVRO_VERSION" 10395e5a571e1a1f6113411f276d2fea

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]




# Stage: connect
FROM connect_base as connect

ARG KAFKA_JDBC_VERSION=5.3.1
ARG POSTGRES_VERSION=42.2.8

ENV DEBEZIUM_VERSION="1.0.0.Final" \
    MAVEN_REPO_CENTRAL="" \
    MAVEN_REPO_INCUBATOR="" \
    MAVEN_DEP_DESTINATION=$KAFKA_CONNECT_PLUGINS_DIR \
    MONGODB_MD5=921d69952d2277b9664c69d2e4fbac9c \
    MYSQL_MD5=41820a2e872676d4e9acaeb3cb2b2c13 \
    POSTGRES_MD5=955675a36c7af5c2cf7f9f85d4abac3b \
    SQLSERVER_MD5=f86d8d403a3265cb4f550ed5ddc457d7 \
    ORACLE_MD5=6557bb454dcef2deb4aeb4e148cc313f

WORKDIR $KAFKA_CONNECT_PLUGINS_DIR

RUN set -eux; \
    \
    docker-maven-download debezium mongodb "$DEBEZIUM_VERSION" "$MONGODB_MD5"; \
    docker-maven-download debezium mysql "$DEBEZIUM_VERSION" "$MYSQL_MD5"; \
    docker-maven-download debezium postgres "$DEBEZIUM_VERSION" "$POSTGRES_MD5"; \
    docker-maven-download debezium sqlserver "$DEBEZIUM_VERSION" "$SQLSERVER_MD5"; \
    docker-maven-download debezium-incubator oracle "$DEBEZIUM_VERSION" "$ORACLE_MD5"; \
    \
    curl -sO http://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/$KAFKA_JDBC_VERSION/kafka-connect-jdbc-$KAFKA_JDBC_VERSION.jar

WORKDIR /kafka/libs
RUN set -eux; \
    \
    curl -sO \
    https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar
