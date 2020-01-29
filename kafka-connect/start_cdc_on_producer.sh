
# Test Kafka Connect
curl -sH "Accept:application/json" \
     localhost:8083/

# Get Kafka Connect connector list
curl -sH "Accept:application/json" \
     localhost:8083/connectors/

# Request data-sink connector starting
curl -i -X POST -sH "Accept:application/json" \
     -sH  "Content-Type:application/json" \
     http://localhost:8083/connectors/ \
     -d @jdbc-sink.json

# Request data-source connector starting
curl -X POST -sH "Accept:application/json" \
     -sH "Content-Type:application/json" \
     localhost:8083/connectors/ \
     -d @mysql-source.json
