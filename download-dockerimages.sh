#!/bin/bash -eu
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


##################################################
# This script pulls docker images from hyperledger
# docker hub repository and Tag it as
# hyperledger/fabric-<image> latest tag
##################################################

#Set ARCH variable i.e ppc64le,s390x,x86_64,i386
ARCH=`uname -m`

dockerFabricPull() {
  local FABRIC_TAG=$1
  for IMAGES in peer orderer ccenv tools; do
      echo "==> FABRIC IMAGE: $IMAGES"
      echo
      docker pull hyperledger/fabric-$IMAGES:$FABRIC_TAG
      docker tag hyperledger/fabric-$IMAGES:$FABRIC_TAG hyperledger/fabric-$IMAGES
  done
}

dockerCaPull() {
      local CA_TAG=$1
      echo "==> FABRIC CA IMAGE"
      echo
      docker pull hyperledger/fabric-ca:$CA_TAG
      docker tag hyperledger/fabric-ca:$CA_TAG hyperledger/fabric-ca
}

dockerOtherPull() {
  local OTHER_TAG=$1
  for IMAGES in javaenv couchdb kafka zookeeper; do
      echo "==> FABRIC OTHER IMAGE"
      echo
      docker pull hyperledger/fabric-$IMAGES:$OTHER_TAG
      docker tag hyperledger/fabric-$IMAGES:$OTHER_TAG hyperledger/fabric-$IMAGES
  done
}

usage() {
      echo "Description "
      echo
      echo "Pulls docker images from hyperledger dockerhub repository"
      echo "tag as hyperledger/fabric-<image>:latest"
      echo
      echo "USAGE: "
      echo
      echo "./download-dockerimages.sh [-c <fabric-ca tag>] [-f <fabric tag> [-t <other-tools tag>]]"
      echo "      -c fabric-ca docker image tag"
      echo "      -f fabric docker image tag"
      echo "      -t other-tools docker image tag"
      echo
      echo
      echo "EXAMPLE:"
      echo "./download-dockerimages.sh -c 1.2.1 -f 1.2.1 -t latest"
      echo
      echo "By default, pulls fabric-ca and fabric 1.0.0-beta docker images"
      echo "from hyperledger dockerhub"
      exit 0
}

while getopts "\?hc:f:t:" opt; do
  case "$opt" in
     c) CA_TAG="$OPTARG"
        echo "Pull CA IMAGES"
        ;;
     f) FABRIC_TAG="$OPTARG"
        echo "Pull FABRIC TAG"
        ;;
     t) OTHER_TAG="$OPTARG"
        echo "Pull OTHER TOOLS TAG"
        ;;
     \?|h) usage
        echo "Print Usage"
        ;;
  esac
done

: ${FABRIC_TAG:="$ARCH-$FABRIC_TAG"}
: ${CA_TAG:="$ARCH-$CA_TAG"}
: ${OTHER_TAG:="$ARCH-$OTHER_TAG"}

echo "===> Pulling fabric Images"
dockerFabricPull ${FABRIC_TAG}

echo "===> Pulling fabric ca Image"
dockerCaPull ${CA_TAG}

echo "===> Pulling fabric other tools Image"
dockerOtherPull ${OTHER_TAG}

echo
echo "===> List out hyperledger docker images"
docker images | grep hyperledger*
