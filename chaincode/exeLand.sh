#!/bin/bash
set -e

export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
LANGUAGE=${1:-"golang"}
CC_SRC_PATH=github.com/lands/go


cd ../network



docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode install -n myland -v 1.1 -p "$CC_SRC_PATH" -l "$LANGUAGE"
echo "check point 1"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C lands -n myland -l "$LANGUAGE" -v 1.1 -c '{"Args":[""]}'
sleep 10
echo "CheckPoint 2"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C lands -n myland -c '{"function":"initLedger","Args":[""]}'

printf "\nTotal execution time : $(($(date +%s) - starttime)) secs ...\n\n\n"

