# Kakfa over Alpine Linux
A building an usage (via docker-compose) instructions for containers that
implement a change data capture (CDC) architecture based on Alpine Linux.


## Architecture
+---------------+     +---------------+     +---------------+
|               |     |               |     |               |
| Kafka-connect | --> | Kafka Cluster | --> | Kafka-connect |
|   (producer)  |     |               |     |  (consumer)   |
|               |     +---------------+     |               |
+---------------+             ^             +---------------+
                              |
                     +-----------------+
                     |                 |
                     | Schema-registry |
                     |                 |
                     +-----------------+

## Zookeeper
- Container settings
  - Principal env-vars:
    - ZOO_MY_ID: Node id
    - ZOO_STANDALONE_ENABLED: standalone (true) or clustered (false) modes
    - ZOO_SERVERS: [hosts string in 'server.id=host:port:port' format][1]

## Kafka
- Container settings
  - Principal env-vars:
    - BROKER_ID: of current node
    - ZOOKEEPER_CONNECT: [Zookeeper host string ('ip_1:port_1,ip_2:port_2')][2]
    - ADVERTISED_LISTENER: [Listener to publish to Zookeeper][3]
    - LISTENERS: [Comma-separated list of Listener's URIs][4]
    - LOG_LEVEL: [Maximum level of error to print][5]

## Kafka Connect
- Container settings
  - Principal env-vars:
    - GROUP_ID: Connect group id
    - BOOTSTRAP_SERVERS: Kafka hosts string
    - CONFIG_STORAGE_TOPIC: configuration topic
    - OFFSET_STORAGE_TOPIC: configuration topic
    - STATUS_STORAGE_TOPIC: configuration topic
    Other variables have 'CONNECT' prefix


## Helper gists
- Consume from kafka-connect container
  - Deserializing Avro (key and value)
```bash
BOOTSTRAP_SERVERS=172.31.3.50:9092,172.31.11.39:9092,172.31.12.84:9092
SCHEMA_REGISTRY_HOST=172.31.29.160;
TABLE_NAME=test20200213.test.usuarios;
./bin/kafka-console-consumer.sh \
  --bootstrap-server $BOOTSTRAP_SERVERS \
  --value-deserializer=io.confluent.kafka.serializers.KafkaAvroDeserializer \
  --key-deserializer=io.confluent.kafka.serializers.KafkaAvroDeserializer \
  --topic $TABLE_NAME \
  --property print.key=true \
  --property value.deserializer.schema.registry.url=http://$SCHEMA_REGISTRY_HOST:8081 \
  --property key.deserializer.schema.registry.url=http://$SCHEMA_REGISTRY_HOST:8081
```

- Kafka Connect connector setup
  - Tranforms message
```json
{
"transforms": "convert_op_ts,convert_current_ts",
"transforms.convert_op_ts.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
"transforms.convert_op_ts.target.type": "Timestamp",
"transforms.convert_op_ts.field": "current_ts",
"transforms.convert_op_ts.format": "yyyy-MM-dd HH:mm:ss.SSSSSS",
"transforms.convert_current_ts.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
"transforms.convert_current_ts.target.type": "Timestamp",
"transforms.convert_current_ts.field": "op_ts",
"transforms.convert_current_ts.format": "yyyy-MM-dd HH:mm:ss.SSSSSS"
}
```


## References
[1]: https://zookeeper.apache.org/doc/r3.6.0/zookeeperAdmin.html
[2]: http://kafka.apache.org/documentation/#zookeeper.connect
[3]: http://kafka.apache.org/documentation/#advertised.listeners
[4]: http://kafka.apache.org/documentation/#listeners
[5]: https://logging.apache.org/log4j/2.0/manual/customloglevels.html
[fundingcircle-debugging-kafka-connect-sinks](https://engineering.fundingcircle.com/blog/2018/01/26/debugging-kafka-connect-sinks/)
