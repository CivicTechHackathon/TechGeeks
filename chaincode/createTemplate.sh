#!/bin/bash
set -e

export MSYS_NO_PATHCONV=1


docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C user -n mycc -c '{"function":"addUser","Args":["A","auser","admin","4210154879858","0"]}'

sleep 5

docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C user -n mycc -c '{"function":"addUser","Args":["Approver","approver","admin","4210112345457","1"]}'

sleep 5

docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C user -n mycc -c '{"function":"addUser","Args":["B","buser","admin","4210134123122","0"]}'

sleep 5

docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/civic.example.com/users/Admin@civic.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C lands -n myland -c '{"function":"createLand","Args":["Land-001","4210154879858","A-97","D","240","Karachi","Central","North Karachi","Residential"]}'
