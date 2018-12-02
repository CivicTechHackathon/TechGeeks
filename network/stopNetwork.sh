echo "Shutting Down the Network..."
docker-compose -f docker-compose.yml kill && docker-compose -f docker-compose.yml down


echo "removing chaincode docker images..."
docker rm $(docker ps -aq)
docker rmi $(docker images dev-* -q)

echo "Stopping and Removing containers"
docker stop $(docker ps -aq)
sleep 1
docker rm $(docker ps -aq)

echo "remove all unused network"
docker network prune



