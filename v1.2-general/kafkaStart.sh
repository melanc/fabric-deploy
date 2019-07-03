#!/bin/bash
NODE_ID=$1
# : ${NODE_ID:=`date +%s`}
: ${NODE_ID:="1"}
echo "NODEID:"$NODE_ID

ENVFILE=.env

start(){
    sed -i "s/COMPOSE_PROJECT_NAME=[0-9A-Za-z]\{1,\}/COMPOSE_PROJECT_NAME=kafka/" ${ENVFILE}
    sed -i "s/ZOOKEEPER_HOST_NAME=z[0-9]\{1,\}/ZOOKEEPER_HOST_NAME=z${NODE_ID}/" ${ENVFILE}
    sed -i "s/ZOOKEEPER_ID=[0-9]\{1,\}/ZOOKEEPER_ID=${NODE_ID}/" ${ENVFILE}
    sed -i "s/KAFKA_HOST_NAME=k[0-9]\{1,\}/KAFKA_HOST_NAME=k${NODE_ID}/" ${ENVFILE}
    sed -i "s/KAFKA_BROKER_ID=[0-9]\{1,\}/KAFKA_BROKER_ID=${NODE_ID}/" ${ENVFILE}
    source .env
    docker-compose -p kafka -f docker-compose-kafka.yaml up  -d
}
start
