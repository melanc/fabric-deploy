#!/bin/bash
docker-compose -p peer -f docker-compose-peer.yaml down
docker-compose -p order -f docker-compose-order.yaml down
docker-compose -p kafka -f docker-compose-kafka.yaml down
sudo rm -rf chainData
