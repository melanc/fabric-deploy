#!/bin/bash
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
echo
echo " ____    _____      _      ____    _____  "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _| "
echo "\___ \    | |     / _ \   | |_) |   | |   "
echo " ___) |   | |    / ___ \  |  _ <    | |   "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|   "
echo

ORGCODE=1
CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
# export FABRIC_CFG_PATH=$PWD/cmdCfg
MYCC=mycc
COUNTER=1
MAX_RETRY=5
ORDERER_NAME=orderer${ORGCODE}.uniledger.com
ORDERER_CA=../crypto-config/ordererOrganizations/uniledger.com/orderers/orderer1.uniledger.com/msp/tlscacerts/tlsca.uniledger.com-cert.pem
PEER0_ORG1_CA=../crypto-config/peerOrganizations/org1.uniledger.com/peers/peer0.org1.uniledger.com/tls/ca.crt
PEER0_ORG2_CA=../crypto-config/peerOrganizations/org2.uniledger.com/peers/peer0.org2.uniledger.com/tls/ca.crt
PEER0_ORG3_CA=../crypto-config/peerOrganizations/org3.uniledger.com/peers/peer0.org3.uniledger.com/tls/ca.crt
ORDERER_SYSCHAN_ID=uniledger-orderer-syschan

echo "Channel name : "$CHANNEL_NAME

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
   		exit 1
	fi
}

setGlobals () {
	PEER=$1
	ORG=$2
	export CORE_PEER_TLS_ENABLED=true
	if [ $ORG -eq 1 ] ; then
		export CORE_PEER_LOCALMSPID="Org1MSP"
		export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
		export CORE_PEER_MSPCONFIGPATH=../crypto-config/peerOrganizations/org1.uniledger.com/users/Admin@org1.uniledger.com/msp
		if [ $PEER -eq 0 ]; then
			export CORE_PEER_ADDRESS=peer0.org1.uniledger.com:7051
		else
			export CORE_PEER_ADDRESS=peer1.org1.uniledger.com:7051
		fi
	elif [ $ORG -eq 3 ] ; then
		export CORE_PEER_LOCALMSPID="Org3MSP"
		export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
		export CORE_PEER_MSPCONFIGPATH=../crypto-config/peerOrganizations/org3.uniledger.com/users/Admin@org3.uniledger.com/msp
		if [ $PEER -eq 0 ]; then
			export CORE_PEER_ADDRESS=peer0.org3.uniledger.com:7051
		else
			export CORE_PEER_ADDRESS=peer1.org3.uniledger.com:7051
		fi
	elif [ $ORG -eq 2 ] ; then
		export CORE_PEER_LOCALMSPID="Org2MSP"
		export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
		export CORE_PEER_MSPCONFIGPATH=../crypto-config/peerOrganizations/org2.uniledger.com/users/Admin@org2.uniledger.com/msp
		if [ $PEER -eq 0 ]; then
			export CORE_PEER_ADDRESS=peer0.org2.uniledger.com:7051
		else
			export CORE_PEER_ADDRESS=peer1.org2.uniledger.com:7051
		fi
	fi

	env |grep CORE
}

checkOSNAvailability() {
	# Use orderer's MSP for fetching system channel config block
	export CORE_PEER_PROFILE_ENABLED=true
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="OrdererMSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=$ORDERER_CA
	export CORE_PEER_MSPCONFIGPATH=../crypto-config/ordererOrganizations/uniledger.com/users/Admin@uniledger.com/msp
	local rc=1
	local starttime=$(date +%s)

	# continue to poll
	# we either get a successful response, or reach TIMEOUT
	while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
	do
		 sleep 3
		 echo "Attempting to fetch system channel '$ORDERER_SYSCHAN_ID' ...$(($(date +%s)-starttime)) secs"
		 if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		 	 echo "a"
			 peer channel fetch 0 -o ${ORDERER_NAME}:7050 -c "$ORDERER_SYSCHAN_ID" >&log.txt
		 else
		 	 echo "b"
			 peer channel fetch 0 0_block.pb -o ${ORDERER_NAME}:7050 -c "$ORDERER_SYSCHAN_ID" --tls --cafile $ORDERER_CA >&log.txt
		 fi
		 test $? -eq 0 && VALUE=$(cat log.txt | awk '/Received block/ {print $NF}')
		 test "$VALUE" = "0" && let rc=0
	done
	cat log.txt
	verifyResult $rc "Ordering Service is not available, Please try again ..."
	echo "===================== Ordering Service is up and running ===================== "
	echo
}

createChannel() {
	setGlobals 0 1
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create -o ${ORDERER_NAME}:7050 -c $CHANNEL_NAME -f ../channel-artifacts/channel.tx >&log.txt
	else
		peer channel create -o ${ORDERER_NAME}:7050 -c $CHANNEL_NAME -f ../channel-artifacts/channel.tx --tls --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

updateAnchorPeers() {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel update -o  ${ORDERER_NAME}:7050 -c $CHANNEL_NAME -f ../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
	else
		peer channel update -o  ${ORDERER_NAME}:7050 -c $CHANNEL_NAME -f ../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Anchor peer update failed"
	echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
	sleep 5
	echo
}

## Sometimes Join takes time hence RETRY atleast for 5 times
joinChannelWithRetry () {
	PEER=$1
	ORG=$2
	echo $PEER $ORG
	setGlobals $PEER $ORG

	peer channel join -b $CHANNEL_NAME.block  >&log.txt
	res=$?
	cat log.txt
	if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
		COUNTER=` expr $COUNTER + 1`
		echo "peer${PEER}.org${ORG} failed to join the channel, Retry after 2 seconds"
		sleep 2
		joinChannelWithRetry $1 $2
	else
		COUNTER=1
	fi
	verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

# joinChannel () {
# 	for org in 1 ; do
# 	    for peer in 0 ; do
# 		    joinChannelWithRetry $peer $org
# 		    echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
# 		    sleep 2
# 		    echo
#         done
# 	done
# }

installChaincode () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	peer chaincode install -n ${MYCC} -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd/ >&log.txt
	res=$?
	cat log.txt
	verifyResult $res "Chaincode installation on peer peer${PEER}.org${ORG} has Failed"
	echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
	echo
}

instantiateChaincode () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	# while 'peer chaincode' command can get the orderer endpoint from the peer (if join was successful),
	# lets supply it directly as we know it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode instantiate -o ${ORDERER_NAME}:7050 -C $CHANNEL_NAME -n ${MYCC} -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')" >&log.txt
	else
		peer chaincode instantiate -o ${ORDERER_NAME}:7050 --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${MYCC} -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')" >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' failed"
	echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
	echo
}

chaincodeQuery () {
	PEER=$1
	ORG=$2
	setGlobals $PEER $ORG
	EXPECTED_RESULT=$3
	echo "===================== Querying on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local starttime=$(date +%s)

	# continue to poll
	# we either get a successful response, or reach TIMEOUT
	while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
	do
        	sleep 3
        	echo "Attempting to Query peer${PEER}.org${ORG} ...$(($(date +%s)-starttime)) secs"
        	peer chaincode query -C $CHANNEL_NAME -n ${MYCC} -c '{"Args":["query","a"]}' >&log.txt
        	test $? -eq 0 && VALUE=$(cat log.txt | egrep '^[0-9]+$')
        	test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
	done
	echo
	cat log.txt
	if test $rc -eq 0 ; then
		echo "===================== Query successful on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
    	else
		echo "!!!!!!!!!!!!!!! Query result on peer${PEER}.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
        	echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
		exit 1
    	fi
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
	# check for uneven number of peer and org parameters
	if [ $(( $# % 2 )) -ne 0 ]; then
        	exit 1
	fi

	PEER_CONN_PARMS=""
	PEERS=""
	while [ "$#" -gt 0 ]; do
		PEER="peer$1.org$2"
		PEERS="$PEERS $PEER"
		PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $PEER.uniledger.com:7051"
		if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
        		TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER$1_ORG$2_CA")
        		PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
        	fi
		# shift by two to get the next pair of peer/org parameters
        	shift; shift
	done
	# remove leading space for output
	PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

# chaincodeInvoke <peer> <org> ...
# Accepts as many peer/org pairs as desired and requests endorsement from each
chaincodeInvoke () {
	parsePeerConnectionParameters $@
	res=$?
	verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "
    CORE_PEER_TLS_ENABLED=true
	setGlobals 0 1
	# while 'peer chaincode' command can get the orderer endpoint from the
	# peer (if join was successful), let's supply it directly as we know
	# it using the "-o" option
	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode invoke -o ${ORDERER_NAME}:7050 -C $CHANNEL_NAME -n ${MYCC} $PEER_CONN_PARMS -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	else
        peer chaincode invoke -o ${ORDERER_NAME}:7050  --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${MYCC} $PEER_CONN_PARMS -c '{"Args":["invoke","a","b","10"]}' >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Invoke execution on PEER$PEER failed "
	echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
	echo
}

# Check for orderering service availablility
echo "Check orderering service availability..."
checkOSNAvailability


# # echo "Creating channel..."
# createChannel

# # # Join all the peers to the channel
# # echo "Having all peers join the channel..."
joinChannelWithRetry 0 ${ORGCODE}

# # # Set the anchor peers for each org in the channel
# # echo "Updating anchor peers for org${ORGCODE}..."
updateAnchorPeers 0 ${ORGCODE}


# # Install chaincode on peer0.org1 and peer2.org2
# # echo "Installing chaincode on peer0.org${ORGCODE}..."
installChaincode 0 ${ORGCODE}


# # Instantiate chaincode on peer0.org2
# # echo "Instantiating chaincode on peer0.org${ORGCODE}..."
# instantiateChaincode 0 ${ORGCODE}

# # Query on chaincode on peer0.org1
# # echo "Querying chaincode on peer0.org${ORGCODE}..."
chaincodeQuery 0 ${ORGCODE} 100

# # # Invoke on chaincode on peer0.org1 and peer0.org2
echo "Sending invoke transaction on peer0.org${ORGCODE} and peer0.org2..."
chaincodeInvoke 0 ${ORGCODE}

echo "Querying chaincode on peer0.org${ORGCODE}..."
chaincodeQuery 0 ${ORGCODE} 90



echo
echo "===================== All GOOD, End-2-End execution completed ===================== "
echo

echo
echo " _____   _   _   ____  "
echo "| ____| | \ | | |  _ \ "
echo "|  _|   |  \| | | | | |"
echo "| |___  | |\  | | |_| |"
echo "|_____| |_| \_| |____/ "
echo

exit 0
