#!/bin/sh

docker-compose -f docker-compose-ca.yaml up -d

sleep 2

docker-compose -f docker-compose-orderer.yaml up -d