#!/bin/sh

command="$1"

# Start ipfs bootstrap node
startBootstrap () {

    # swarm key
    swarmKey

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose --log-level ERROR up -d bootstrap_node

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
  echo "usage: private-ipfs.sh [startBoostrap|startIpfs]"
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
