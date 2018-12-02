
rm -fr config/*
#rm -fr crypto-config/*


# Intializing Variables
export MSYS_NO_PATHCONV=1
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME1=user
CHANNEL_NAME2=lands
CHANNEL_NAME3=transfer


echo "Generating Crypto Materials in to crypto-config folder..."
#cryptogen generate --config=./crypto-config.yaml

echo "Generating Genesis Block Configuration in config folder..."
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block

echo "Creating Channel Configuration in config folder...1"
configtxgen -profile OneOrgChannel1 -outputCreateChannelTx ./config/channel1.tx -channelID $CHANNEL_NAME1

echo "Creating Channel Configuration in config folder...2"
configtxgen -profile OneOrgChannel2 -outputCreateChannelTx ./config/channel2.tx -channelID $CHANNEL_NAME2

echo "Creating Channel Configuration in config folder...3"
configtxgen -profile OneOrgChannel3 -outputCreateChannelTx ./config/channel3.tx -channelID $CHANNEL_NAME3


# generate anchor peer transaction
# configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/CIVICMSPanchors.tx -channelID $CHANNEL_NAME1 -asOrg CIVICMSP

echo "Shutting down if any previous network is running..."
docker-compose -f docker-compose.yml down

echo "##### STARTING NETWORK #####"
docker-compose -f docker-compose.yml up -d

# wait for Hyperledger Fabric to start
# Setting Timeout 
export FABRIC_START_TIMEOUT=50

sleep ${FABRIC_START_TIMEOUT}

echo "Creating channel..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME1 -f /etc/hyperledger/configtx/channel1.tx

echo "Creating channel..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME2 -f /etc/hyperledger/configtx/channel2.tx

echo "Creating channel..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME3 -f /etc/hyperledger/configtx/channel3.tx



echo "##########################################"
echo "######### peer0 joining channels #########"
echo "##########################################"

echo "Joining peer0.civic.example.com to the channel...USER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel join -b user.block

echo "Joining peer0.org1.example.com to the channel...LANDS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel join -b lands.block

echo "Joining peer0.org1.example.com to the channel...TRANSFER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel join -b transfer.block




echo "##########################################"
echo "######### peer1 Fetching channels #########"
echo "##########################################"

echo "peer1.org1.example.com fetching USER Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel fetch 0 user.block -c user -o orderer.example.com:7050

echo "peer1.org1.example.com fetching LANDS Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel fetch 0 lands.block -c lands -o orderer.example.com:7050

echo "peer1.org1.example.com fetching TRANSFER Channel Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel fetch 0 transfer.block -c transfer -o orderer.example.com:7050


echo "##########################################"
echo "######### peer1 joining channels #########"
echo "##########################################"

echo "Joining peer1.org1.example.com to the channel...USER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel join -b user.block

echo "Joining peer1.org1.example.com to the channel...LANDS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel join -b lands.block

echo "Joining peer1.org1.example.com to the channel...TRANSFER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel join -b transfer.block



echo "##########################################"
echo "######### peer2 Fetching channels #########"
echo "##########################################"

echo "peer2.org1.example.com fetching USER Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel fetch 0 user.block -c user -o orderer.example.com:7050

echo "peer2.org1.example.com fetching LANDS Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel fetch 0 lands.block -c lands -o orderer.example.com:7050

echo "peer2.org1.example.com fetching TRANSFER Channel Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel fetch 0 transfer.block -c transfer -o orderer.example.com:7050


echo "##########################################"
echo "######### peer2 joining channels #########"
echo "##########################################"

echo "Joining peer2.org1.example.com to the channel...USER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel join -b user.block

echo "Joining peer2.org1.example.com to the channel...LANDS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel join -b lands.block

echo "Joining peer2.org1.example.com to the channel...TRANSFER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel join -b transfer.block





echo "##########################################"
echo "######### peer3 Fetching channels #########"
echo "##########################################"

echo "peer2.org1.example.com fetching USER Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel fetch 0 user.block -c user -o orderer.example.com:7050

echo "peer2.org1.example.com fetching LANDS Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel fetch 0 lands.block -c lands -o orderer.example.com:7050

echo "peer2.org1.example.com fetching TRANSFER Channel Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel fetch 0 transfer.block -c transfer -o orderer.example.com:7050


echo "##########################################"
echo "######### peer3 joining channels #########"
echo "##########################################"

echo "Joining peer2.org1.example.com to the channel...USER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel join -b user.block

echo "Joining peer2.org1.example.com to the channel...LANDS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel join -b lands.block

echo "Joining peer2.org1.example.com to the channel...TRANSFER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel join -b transfer.block




echo "##########################################"
echo "######### peer4 Fetching channels #########"
echo "##########################################"

echo "peer2.org1.example.com fetching USER Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel fetch 0 user.block -c user -o orderer.example.com:7050

echo "peer2.org1.example.com fetching LANDS Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel fetch 0 lands.block -c lands -o orderer.example.com:7050

echo "peer2.org1.example.com fetching TRANSFER Channel Configuration Block..."
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel fetch 0 transfer.block -c transfer -o orderer.example.com:7050


echo "##########################################"
echo "######### peer4 joining channels #########"
echo "##########################################"

echo "Joining peer2.org1.example.com to the channel...USER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel join -b user.block

echo "Joining peer2.org1.example.com to the channel...LANDS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel join -b lands.block

echo "Joining peer2.org1.example.com to the channel...TRANSFER"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel join -b transfer.block





echo "#################################################"
echo "######### DISPLAYING PEERS CHANNEL LIST #########"
echo "#################################################"

sleep 2

echo "LISTING PEER0 CHANNELS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer0.civic.example.com peer channel list

sleep 2

echo "LISTING PEER1 CHANNELS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer1.civic.example.com peer channel list

sleep 2

echo "LISTING PEER2 CHANNELS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer2.civic.example.com peer channel list

sleep 2

echo "LISTING PEER3 CHANNELS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer3.civic.example.com peer channel list

sleep 2

echo "LISTING PEER4 CHANNELS"
docker exec -e "CORE_PEER_LOCALMSPID=CIVICMSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@civic.example.com/msp" peer4.civic.example.com peer channel list

sleep 2


echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%        DISPLAYING DOCKER CONTAINERS        %%"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
sleep 4
docker ps 

