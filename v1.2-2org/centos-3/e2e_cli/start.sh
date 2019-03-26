#!/bin/sh

docker-compose -f docker-zk.yaml up -d

sleep 2

docker-compose -f docker-kafka.yaml up -d

sleep 2

docker-compose -f docker-compose-orderer.yaml up -d

sleep 2 

docker-compose -f docker-compose-peer.yaml up -d