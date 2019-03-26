#!/bin/sh

docker-compose -f docker-zk.yaml up -d

sleep 2

docker-compose -f docker-kafka.yaml up -d