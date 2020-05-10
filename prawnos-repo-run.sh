#!/bin/bash

CONFIG_FOLDER=/root/reprepro-config/
WEBSERVER_PORT=8080
SSH_PORT=2222

IMAGE_NAME="prawnos/reprepro"

echo -e "Configuration from: '$CONFIG_FOLDER'\n" \
        "Webserver mapped to: '$WEBSERVER_PORT'\n" \
        "SSH daemon mapped to: '$SSH_PORT'\n" \
        ""

echo "Image built succesfully; starting the build command!"
docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -d --restart unless-stopped $IMAGE_NAME

