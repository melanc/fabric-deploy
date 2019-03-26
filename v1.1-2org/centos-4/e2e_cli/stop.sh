#!/bin/sh

docker rm -f $(docker ps -a | grep fabric | awk '{print $1}') && rm -rf chainData && rm -rf base/chainData

docker rm -f $(docker ps -a | grep educc | awk '{print $1}')

docker rmi -f $(docker images | grep educc | awk '{print $3}')