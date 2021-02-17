#!/bin/sh

command="$1"

BOOTSTRAP_LOG_FILE=./private-network/logs/bootstrap_logs.log

# Remove the swarm.key file
clean () {
    if [ -f ./private-network/.ipfs/swarm.key ]; then
        sudo rm ./private-network/.ipfs/swarm.key
    fi

    if [ -f ./ipfs.bootstrap.container ]; then
        sudo rm ./ipfs.bootstrap.container
    fi   
}

# Create missing directory
volumeSetup () {
    mkdir private-network/.ipfs/
    mkdir private-network/logs
}

# Start ipfs bootstrap node
startBootstrap () {

    stopContainers

    clean

    volumeSetup

    swarmKey

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose run -d --rm bootstrap_node > ipfs.bootstrap.container

    # Number of seconds waited for each tick (proportional to the depth of the Merkle Tree)
    echo "Waiting for 15 seconds ... ⏳"
    sleep 15
    docker logs $(cat ./ipfs.bootstrap.container) | grep "PeerID" > peerId
}

# Start ipfs node
startIpfs () {

    # init.sh executable
    chmod +x private-network/init.sh

    # Run an ipfs node
    docker-compose --log-level ERROR up -d ipfs_node

}

# Generate a swarm key
swarmKey () {

    # Generate a swarm key and output into a file 
    docker run --rm golang:1.9 sh -c 'go get github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen && ipfs-swarm-key-gen' >> private-network/.ipfs/swarm.key
}

# Stop all containers
stopContainers () {

  echo "Stopping containers..."
	docker-compose --log-level ERROR down -v --remove-orphans
}

# Show help
help () {
  echo "usage: private-ipfs.sh [start-bootstrap|start-ipfs|stop]"
}


# Start, stop, remove
case "${command}" in
        "help")
    help
    ;;
        "start-bootstrap")
    startBootstrap
    ;;
        "start-ipfs")
    startIpfs
    ;;
         "stop")
    stopContainers
    ;;
  *)
    echo "Command not Found."
    help
    exit 127;
    ;;
esac

