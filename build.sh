#!/bin/bash

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not installed, please install it first."
    exit 1
fi

max_retries=50
retries=0

docker-compose down

while [ $retries -lt $max_retries ]; do

    docker-compose build

    if [ $? -eq 0 ]; then
        docker-compose up -d
        echo "Docker Compose project has been successfully rebuilt and started."
        exit 0
    else
        echo "Build failed, retry $((retries+1)) in progress..."
        retries=$((retries+1))
        sleep 5
    fi
done

echo "The maximum number of retries was reached and the Docker Compose project could not be successfully built."
exit 1
