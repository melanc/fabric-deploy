#!/bin/bash
NODE_ID=$1
# : ${NODE_ID:=`date +%s`}
: ${NODE_ID:="1"}
echo "NODEID:"$NODE_ID

ENVFILE=.env

start(){
    sed -i "s/COMPOSE_PROJECT_NAME=[0-9A-Za-z]\{1,\}/COMPOSE_PROJECT_NAME=order/" ${ENVFILE}
    sed  -i "s/orderer[0-9].uniledger.com/orderer${NODE_ID}.uniledger.com/" ${ENVFILE}
    source .env
    docker-compose -p order -f docker-compose-order.yaml  up -d
}
start
