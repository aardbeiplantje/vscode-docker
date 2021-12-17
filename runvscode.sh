#!/bin/bash

VSCODE_OAUTH2_CONFIG=${VSCODE_OAUTH2_CONFIG:-~/.vscode-docker/vscode-${WHAT:-github}.sh}
if [ -f "$VSCODE_OAUTH2_CONFIG" ]; then
    . "$VSCODE_OAUTH2_CONFIG"
fi

USER=${USER:-openvscode-server}
HOME=${HOME:-/home/$USER}
DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-vscode/workspace}
DOCKER_TAG=${DOCKER_TAG:-latest}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-images_$USER}
DOCKER_IMAGE="$DOCKER_REPOSITORY/$DOCKER_IMAGE_NAME:$DOCKER_TAG"
VSCODE_HOME=${VSCODE_HOME:-/home/workspace}
unset SSH_AUTH_SOCK
unset SSH_AGENT_PID
if [ "$UID" == 0 ]; then
    eval $(su - $USER -c "echo SSH_AUTH_SOCK=\$SSH_AUTH_SOCK")
fi
do_auth=""
if [ ! -z "$SSH_AUTH_SOCK" ]; then
    ssh_sock=$(readlink -f $SSH_AUTH_SOCK)
    do_auth=" -v $ssh_sock:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent "
fi
docker build \
    -t $DOCKER_IMAGE \
    --build-arg OAUTH_PROXY_RELEASE_TAG=v5.0.0 \
    --build-arg RELEASE_TAG=openvscode-server-v1.61.0 \
    vscode-docker/
DOCKER_RUN_NAME=${DOCKER_RUN_NAME:-vscode_${USER}}
docker stop "$DOCKER_RUN_NAME"
docker rm "$DOCKER_RUN_NAME"
docker image prune -f
docker run -it --init \
    -d \
    -p 127.0.0.1:3000:3000 \
    -e USER_UID=$(id -u $USER) \
    -e USER_GID=$(id -g $USER) \
    -e USERNAME=$USER \
    -e GROUP=users \
    --name "$DOCKER_RUN_NAME" \
    $do_auth \
    -e VSCODE_HOME=$VSCODE_HOME \
    -e OAUTH2_PROXY_CLIENT_ID=$OAUTH2_PROXY_CLIENT_ID \
    -e OAUTH2_PROXY_CLIENT_SECRET=$OAUTH2_PROXY_CLIENT_SECRET \
    -e OAUTH2_PROXY_PROVIDER=$OAUTH2_PROXY_PROVIDER \
    -e OAUTH2_PROXY_GITHUB_ORG=$OAUTH2_PROXY_GITHUB_ORG \
    -e OAUTH2_PROXY_EMAIL_DOMAINS=$OAUTH2_PROXY_EMAIL_DOMAINS \
    -e OAUTH2_PROXY_OIDC_ISSUER_URL=$OAUTH2_PROXY_OIDC_ISSUER_URL \
    -v "$HOME/workspace:${VSCODE_HOME}:cached" \
    $DOCKER_IMAGE
