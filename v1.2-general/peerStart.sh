#!/bin/bash
PEER_ID=$1
ORG_ID=$2
: ${PEER_ID:="0"}
: ${ORG_ID:="1"}
echo "PEER_ID:"$PEER_ID
echo "ORG_ID:"$ORG_ID

ENVFILE=.env

start(){
    sed -i "s/COMPOSE_PROJECT_NAME=[0-9A-Za-z]\{1,\}/COMPOSE_PROJECT_NAME=peer/" ${ENVFILE}
    sed -i "s/peer[0-9]\{1,\}.org[0-9]\{1,\}.uniledger.com/peer${PEER_ID}.org${ORG_ID}.uniledger.com/" ${ENVFILE}
    sed -i "s/org[0-9]\{1,\}.uniledger.com/org${ORG_ID}.uniledger.com/" ${ENVFILE}
    sed -i "s/PEER_LOCALMSPID=Org[0-9]\{1,\}MSP/PEER_LOCALMSPID=Org${ORG_ID}MSP/" ${ENVFILE}
    source .env
    docker-compose -p peer -f docker-compose-peer.yaml up -d 
}
start
