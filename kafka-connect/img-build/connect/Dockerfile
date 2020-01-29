FROM krealo/connectbase-alpine-zulu:0.6
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
    curl -sO https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar
