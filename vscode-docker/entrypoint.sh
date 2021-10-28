#!/bin/bash

set -x

VSCODE_HOME=${VSCODE_HOME:-/home/workspace}
USERNAME=${USERNAME:-openvscode-server}
USER_UID=${USER_UID:-$(id -u)}
USER_GID=${USER_GID:-$(id -g)}
userdel openvscode-server
groupdel openvscode-server
userdel $USERNAME
groupdel $GROUP
if [ ! -z "$USER_GID" -a ! -z "$USER_UID" -a ! -z "$USERNAME" ]; then
    groupadd --gid $USER_GID $GROUP
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
fi
cd $VSCODE_HOME
mkdir -p /var/tmp/nginx
nginx -c /etc/nginx/nginx.conf &
(
    set +x
    export OAUTH2_PROXY_COOKIE_SECRET=$(openssl rand -base64 32 | tr -- '+/' '-_')
    export OAUTH2_PROXY_CLIENT_ID=$OAUTH2_PROXY_CLIENT_ID
    export OAUTH2_PROXY_CLIENT_SECRET=$OAUTH2_PROXY_CLIENT_SECRET
    export OAUTH2_PROXY_EMAIL_DOMAINS=${OAUTH2_PROXY_EMAIL_DOMAINS:-*}
    export OAUTH2_PROXY_GITHUB_ORG
    export OAUTH2_PROXY_PROVIDER=${OAUTH2_PROXY_PROVIDER:-github}
    export OAUTH2_PROXY_OIDC_ISSUER_URL
    export OAUTH2_PROXY_REDIRECT_URL=http://localhost:3000/oauth2/callback
    exec /opt/oauth2_proxy/oauth2_proxy/oauth2_proxy
) &
exec env -i - /usr/sbin/gosu $USER_UID $SHELL -c '
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export HOME='$VSCODE_HOME'
export USER='$USERNAME'
export OPENVSCODE_SERVER_ROOT='$OPENVSCODE_SERVER_ROOT'
export EDITOR=code
export VISUAL=code
export SHELL=/bin/bash
export GIT_EDITOR="code --wait"
eval "$(ssh-agent -s)"
exec $SHELL $OPENVSCODE_SERVER_ROOT/server.sh --no-proxy-server --port 3030 '"$*"
