Kafka Connect
=============
# Logging
- setup loglevel passing LOG var to container

# SerDe (serializer/deserializer)
- To use Avro, setup a schema registry server and pass next vars to container
  - KEY_CONVERTER=io.confluent.connect.avro.AvroConverter
  - VALUE_CONVERTER=io.confluent.connect.avro.AvroConverter
  - CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=http://schema-registry:8081
  - CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=http://schema-registry:8081

#Kafka Connect Sink
  - Debugging
    - [fundingcircle-debugging-kafka-connect-sinks](https://engineering.fundingcircle.com/blog/2018/01/26/debugging-kafka-connect-sinks/)


#Consume from kafka-connect container
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
> --from-beginning

#Kafka Connect Single Message Transform (SMT)
- Tranforms message
```json
{
"_comment": "Use SMT to cast op_ts and current_ts to timestamp datatype (TimestampConverter is Kafka >=0.11 / Confluent Platform >=3.3). Format from https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html",
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

#Op 1: Key serializing config on Connector's JSON Config file
key.serializer=org.apache.kafka.common.serialization.StringSerializer
key.converter=org.apache.kafka.connect.storage.StringConverter

"io.debezium.connector.mysql.MySqlConnector"


#Kafka Server SSH Tunnel Connection
setup a virtual interface for each Kafka broker
open a tunnel to each broker so that broker n is bound to virtual interface n
configure your /etc/hosts file so that the advertised hostname of broker n
is resolved to the ip of the virtual interface n.

Kafka brokers:
broker1 (advertised as broker1.mykafkacluster)
broker2 (advertised as broker2.mykafkacluster)

Virtual interfaces:
veth1 (192.168.1.1)
veth2 (192.168.1.2)

Tunnels:
broker1: ssh -L 192.168.1.1:9092:broker1.mykafkacluster:9092 jumphost
broker2: ssh -L 192.168.1.2:9092:broker1.mykafkacluster:9092 jumphost

/etc/hosts:
192.168.1.1 broker1.mykafkacluster
192.168.1.2 broker2.mykafkacluster

If you configure your system like this you should be able reach all the
brokers in your Kafka cluster.



Note: if you configured your Kafka brokers to advertise an ip address
instead of a hostname the procedure can still work but you need to
configure the virtual interfaces with the same ip address that the broker
advertises.


#Using container debezium/tooling
```bash
kafkacat -L -b kafka-src:29092 -C -o beginning \
  -t culqi.culqidb.comercio_validacion_riesgo
````

