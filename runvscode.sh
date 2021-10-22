#!/bin/bash

USER=${USER:-openvscode-server}
HOME=${HOME:-/home/$USER}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-vscode/workspace}
DOCKER_TAG=latest
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-images_$USER}
DOCKER_IMAGE="$DOCKER_REPOSITORY/$DOCKER_IMAGE_NAME:$DOCKER_TAG"
VSCODE_HOME=/home/workspace

docker build \
    -t $DOCKER_IMAGE \
    --build-arg RELEASE_TAG=openvscode-server-v1.61.0 \
    vscode-docker/
docker image prune -f
docker run -it --rm --init \
    -p 127.0.0.1:3000:3000 \
    -e USER_UID=$(id -u) \
    -e USER_GID=$(id -g) \
    -e USERNAME=$USER \
    -e GROUP=users \
    -e VSCODE_HOME=$VSCODE_HOME \
    -v "$HOME/workspace:${VSCODE_HOME}:cached" \
    $DOCKER_IMAGE \
    --no-proxy-server
