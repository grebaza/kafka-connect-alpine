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
    CONFLUENT_VERSION=5.3.1 \
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
        "$CONFLUENT_VERSION" 0a5b55833174edbb43bfea083e9c8427; \
    docker-maven-download confluent kafka-avro-serializer \
        "$CONFLUENT_VERSION" 79afbe85a56b837a19968d9cdb9d88ae; \
    docker-maven-download confluent kafka-schema-registry-client \
        "$CONFLUENT_VERSION" 6fc24c86bddf289c295f9ff7faa4f5ee; \
    docker-maven-download confluent common-config \
        "$CONFLUENT_VERSION" 4a05ff77f0dafe5310894a7fe5ff1e26; \
    docker-maven-download confluent common-utils \
        "$CONFLUENT_VERSION" 0d08ae0b949613a4faeecc2cbf27b5c7; \
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

ENV DEBEZIUM_VERSION="1.1.1.Final" \
    MAVEN_REPO_CENTRAL="" \
    MAVEN_REPO_INCUBATOR="" \
    MAVEN_DEP_DESTINATION=$KAFKA_CONNECT_PLUGINS_DIR \
    MONGODB_MD5=0071931fe4e359d4785c473e1117c72c \
    MYSQL_MD5=8930fee8a22b00567f7998819c24f08d \
    POSTGRES_MD5=7c0a9f5f9ce03a1c00200392d5e7f09b \
    SQLSERVER_MD5=03728bc40e1d375e4a4cea1294f6cb42 \
    ORACLE_MD5=4ef6c6527ae902092bb49e00280ffd49 \
    DB2_MD5=8f776cc3610514dd5e575a1b01993abf

WORKDIR $KAFKA_CONNECT_PLUGINS_DIR

RUN set -eux; \
    \
    docker-maven-download debezium mongodb "$DEBEZIUM_VERSION" "$MONGODB_MD5"; \
    docker-maven-download debezium mysql "$DEBEZIUM_VERSION" "$MYSQL_MD5"; \
    docker-maven-download debezium postgres "$DEBEZIUM_VERSION" "$POSTGRES_MD5"; \
    docker-maven-download debezium sqlserver "$DEBEZIUM_VERSION" "$SQLSERVER_MD5"; \
    docker-maven-download debezium-incubator oracle "$DEBEZIUM_VERSION" "$ORACLE_MD5"; \
    docker-maven-download debezium-incubator db2 "$DEBEZIUM_VERSION" "$DB2_MD5"; \
    \
    curl -sO http://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/$KAFKA_JDBC_VERSION/kafka-connect-jdbc-$KAFKA_JDBC_VERSION.jar

WORKDIR /kafka/libs
RUN set -eux; \
    \
    curl -sO \
    https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar
