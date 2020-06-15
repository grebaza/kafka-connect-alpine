# Stage: connect-base
ARG KAFKA_IMAGE
FROM $KAFKA_IMAGE as connect_base

EXPOSE 8083
VOLUME ["/kafka/data","/kafka/logs","/kafka/config"]

COPY docker-entrypoint.sh /
COPY log4j.properties $KAFKA_HOME/config/log4j.properties
COPY docker-maven-download.sh /usr/local/bin/docker-maven-download
COPY docker-chub-download.sh /usr/local/bin/docker-chub-download

#
# Set up the plugins directory ...
#
ENV KAFKA_CONNECT_PLUGINS_DIR=$KAFKA_HOME/connect \
    CONNECT_PLUGIN_PATH=$KAFKA_CONNECT_PLUGINS_DIR \
    MAVEN_DEP_DESTINATION=$KAFKA_HOME/libs \
    CONFLUENT_VERSION=5.5.0 \
    AVRO_VERSION=1.9.2 \
    AVRO_JACKSON_VERSION=1.9.13 \
    KAFKA_CONNECT_AVRO_CONVERTER_MD5=16c38a7378032f850f0293b7654aa6bf \
    KAFKA_CONNECT_AVRO_DATA_MD5=63022db9533689968540f45be705786d \
    KAFKA_AVRO_SERIALIZER_MD5=b1379606e1dcc5d7b809c82abe294cc7 \
    KAFKA_SCHEMA_SERIALIZER_MD5=b68a7eebf7ce6a1b826bd5bbb443b176 \
    KAFKA_SCHEMA_REGISTRY_CLIENT_MD5=e3631a8a3fe10312a727e9d50fcd5527 \
    COMMON_CONFIG_MD5=e1a4dc2b6d1d8d8c2df47db580276f38 \
    COMMON_UTILS_MD5=ad9e39d87c6a9fa1a9b19e6ce80392fa \
    JACKSON_CORE_ASL_MD5=319c49a4304e3fa9fe3cd8dcfc009d37 \
    JACKSON_MAPPER_ASL_MD5=1750f9c339352fc4b728d61b57171613 \
    AVRO_MD5=cb70195f70f52b27070f9359b77690bb

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
          "$CONFLUENT_VERSION" "$KAFKA_CONNECT_AVRO_CONVERTER_MD5"; \
    docker-maven-download confluent kafka-connect-avro-data \
          "$CONFLUENT_VERSION" "$KAFKA_CONNECT_AVRO_DATA_MD5"; \
    docker-maven-download confluent kafka-avro-serializer \
          "$CONFLUENT_VERSION" "$KAFKA_AVRO_SERIALIZER_MD5"; \
    docker-maven-download confluent kafka-schema-serializer \
          "$CONFLUENT_VERSION" "$KAFKA_SCHEMA_SERIALIZER_MD5"; \
    docker-maven-download confluent kafka-schema-registry-client \
          "$CONFLUENT_VERSION" "$KAFKA_SCHEMA_REGISTRY_CLIENT_MD5"; \
    docker-maven-download confluent common-config \
          "$CONFLUENT_VERSION" "$COMMON_CONFIG_MD5"; \
    docker-maven-download confluent common-utils \
          "$CONFLUENT_VERSION" "$COMMON_UTILS_MD5"; \
    docker-maven-download central org/codehaus/jackson jackson-core-asl \
          "$AVRO_JACKSON_VERSION" "$JACKSON_CORE_ASL_MD5"; \
    docker-maven-download central org/codehaus/jackson jackson-mapper-asl \
          "$AVRO_JACKSON_VERSION" "$JACKSON_MAPPER_ASL_MD5"; \
    docker-maven-download central org/apache/avro avro \
          "$AVRO_VERSION" "$AVRO_MD5"

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]




# Stage: connect
FROM connect_base as connect

ARG POSTGRES_VERSION=42.2.14

ENV DEBEZIUM_VERSION="1.1.1.Final" \
    MAVEN_REPO_CENTRAL="" \
    MAVEN_REPO_INCUBATOR="" \
    MAVEN_DEP_DESTINATION=$KAFKA_CONNECT_PLUGINS_DIR \
    CHUB_DEP_DESTINATION=$KAFKA_CONNECT_PLUGINS_DIR \
    MONGODB_MD5=0071931fe4e359d4785c473e1117c72c \
    MYSQL_MD5=8930fee8a22b00567f7998819c24f08d \
    POSTGRES_MD5=7c0a9f5f9ce03a1c00200392d5e7f09b \
    SQLSERVER_MD5=03728bc40e1d375e4a4cea1294f6cb42 \
    ORACLE_MD5=4ef6c6527ae902092bb49e00280ffd49 \
    DB2_MD5=8f776cc3610514dd5e575a1b01993abf \
    CONNECT_JDBC_MD5=099919634ac922363a57ed499f6a91a6 \
    CONNECT_TRANSFORMS="confluentinc/connect-transforms" \
    CONNECT_TRANSFORMS_VERSION="1.3.2" \
    CONNECT_HTTP_VERSION="0.7.6" \
    CONNECT_HTTP_MD5=8486833a2e6958f3998620cd076b7ecf \
    MYSQL_VERSION_CENTRAL="8.0.20" \
    MYSQL_MD5_CENTRAL=48d69b9a82cbe275af9e45cb80f6b15f \
    POSTGRES_MD5_CENTRAL=79869645ab65d5ef28024fc96bb1ce28

WORKDIR $KAFKA_CONNECT_PLUGINS_DIR
RUN set -eux; \
    \
    docker-maven-download debezium mongodb "$DEBEZIUM_VERSION" "$MONGODB_MD5"; \
    docker-maven-download debezium mysql "$DEBEZIUM_VERSION" "$MYSQL_MD5"; \
    docker-maven-download debezium postgres "$DEBEZIUM_VERSION" "$POSTGRES_MD5"; \
    docker-maven-download debezium sqlserver "$DEBEZIUM_VERSION" "$SQLSERVER_MD5"; \
    docker-maven-download debezium-incubator oracle "$DEBEZIUM_VERSION" "$ORACLE_MD5"; \
    docker-maven-download debezium-incubator db2 "$DEBEZIUM_VERSION" "$DB2_MD5"; \
    docker-maven-download confluent kafka-connect-jdbc "$CONFLUENT_VERSION" "$CONNECT_JDBC_MD5"; \
    \
    docker-chub-download "$CONNECT_TRANSFORMS" "$CONNECT_TRANSFORMS_VERSION"; \
    docker-maven-download central-plugin com/github/castorm kafka-connect-http \
          "$CONNECT_HTTP_VERSION" "$CONNECT_HTTP_MD5"

RUN set -eux; \
    \
    MAVEN_DEP_DESTINATION=/kafka/libs; \
    docker-maven-download central mysql/mysql-connector-java \
          "$MYSQL_VERSION_CENTRAL" "$MYSQL_MD5_CENTRAL"; \
    docker-maven-download central org/postgresql/postgresql \
          "$POSTGRES_VERSION" "$POSTGRES_MD5_CENTRAL"
