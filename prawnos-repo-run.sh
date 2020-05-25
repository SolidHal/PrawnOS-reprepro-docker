#!/bin/bash



export CONFIG_FOLDER=~/reprepro-dockerfs/reprepro-config/
export REPO_FOLDER=~/reprepro-dockerfs/repos/
WEBSERVER_PORT=8080
SSH_PORT=2222

IMAGE_NAME="prawnos/reprepro"

echo -e "Configuration from: '$CONFIG_FOLDER'\n" \
        "Repos folder from: '$REPO_FOLDER'\n" \
        "Webserver mapped to: '$WEBSERVER_PORT'\n" \
        "SSH daemon mapped to: '$SSH_PORT'\n" \
        ""

docker run -v $CONFIG_FOLDER:/srv/ -v $REPO_FOLDER:/var/www/repos/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -d --restart always $IMAGE_NAME

