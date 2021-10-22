#!/bin/bash

set -x

VSCODE_HOME=${VSCODE_HOME:-/home/workspace}
USERNAME=${USERNAME:-openvscode-server}
WHERE=${WHERE:-/home/$USERNAME}
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
exec /usr/sbin/gosu $USER_UID $SHELL -c '
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export HOME='$VSCODE_HOME'
export USER='$USERNAME'
export EDITOR=code
export VISUAL=code
export SHELL=/bin/bash
export GIT_EDITOR="code --wait"
eval "$(ssh-agent -s)"; exec '$SHELL' '$WHERE'/server.sh '"$*"
