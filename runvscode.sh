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
    --build-arg OAUTH_PROXY_RELEASE_TAG=v5.0.0 \
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
    -e OAUTH2_PROXY_CLIENT_ID=$OAUTH2_PROXY_CLIENT_ID \
    -e OAUTH2_PROXY_CLIENT_SECRET=$OAUTH2_PROXY_CLIENT_SECRET \
    -e OAUTH2_PROXY_GITHUB_ORG=$OAUTH2_PROXY_GITHUB_ORG \
    -e OAUTH2_PROXY_EMAIL_DOMAINS=$OAUTH2_PROXY_EMAIL_DOMAINS \
    -v "$HOME/workspace:${VSCODE_HOME}:cached" \
    $DOCKER_IMAGE
