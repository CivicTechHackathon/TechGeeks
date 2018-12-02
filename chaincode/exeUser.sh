#!/bin/bash
set -e

export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
LANGUAGE=${1:-"golang"}
CC_SRC_PATH=github.com/user/go


cd ../network



docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode install -n mycc -v 1.3 -p "$CC_SRC_PATH" -l "$LANGUAGE"
echo "check point 1"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C user -n mycc -l "$LANGUAGE" -v 1.3 -c '{"Args":[""]}'
sleep 10
echo "CheckPoint 1"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C user -n mycc -c '{"function":"initLedger","Args":[""]}'

printf "\nTotal execution time : $(($(date +%s) - starttime)) secs ...\n\n\n"

