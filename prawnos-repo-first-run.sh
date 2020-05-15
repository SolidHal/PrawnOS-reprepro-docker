#!/bin/bash

export CONFIG_FOLDER=~/reprepro-config/
export HOSTNAME="deb.prawnos.com"
export PROJECT_NAME="PrawnOS"
export CODE_NAME="buster"
export WEBSERVER_PORT=8080
export SSH_PORT=2222

docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 \
       -e HOSTNAME=$HOSTNAME \
       -e PROJECT_NAME=$PROJECT_NAME \
       -e CODE_NAME=$CODE_NAME \
       -it prawnos/reprepro
