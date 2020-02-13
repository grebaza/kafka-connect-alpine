#!/usr/bin/env bash

SERVICE=connect
UP_SERVICE=false
COMMAND="start"

# Check if service is running
if [ -z $(docker-compose ps -q $SERVICE) ] \
     || [ -z `docker ps -q --no-trunc \
          | grep $(docker-compose ps -q $SERVICE)` ]; then
  UP_SERVICE=true
  COMMAND="up -d"
fi

# Starting service
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.production.yml \
  $COMMAND

