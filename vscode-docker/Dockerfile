# start from ubuntu
FROM ubuntu:latest

ARG RELEASE_TAG
ARG OAUTH_PROXY_RELEASE_TAG
ARG USERNAME=openvscode-server
ARG USER_UID=12321
ARG USER_GID=$USER_UID

USER root

# for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN cat /etc/resolv.conf; echo "nameserver 8.8.8.8" > /etc/resolv.conf

RUN truncate -s0 /tmp/preseed.cfg;                                           \
    echo "tzdata tzdata/Areas select Europe"          >> /tmp/preseed.cfg;   \
    echo "tzdata tzdata/Zones/Europe select Brussels" >> /tmp/preseed.cfg;   \
    debconf-set-selections /tmp/preseed.cfg;                                 \
    rm -f /etc/timezone /etc/localtime;                                      \
    apt-get update && apt-get install -y     \
    tar                                      \
    bash                                     \
    lsof                                     \
    strace                                   \
    net-tools                                \
    gzip                                     \
    git                                      \
    wget                                     \
    curl                                     \
    sudo                                     \
    nginx                                    \
    gosu                                     \
    vim                                      \
    perl                                     \
    perl-base                                \
    perl-doc                                 \
    perl-modules-5.30                        \
    manpages                                 \
    manpages-dev                             \
    manpages-posix                           \
    manpages-posix-dev                       \
    python3.8                                \
    python3.8-dev                            \
    cargo                                    \
    libstdc++-9-dev:amd64                    \
    libgcc-9-dev:amd64                       \
    libnginx-mod-http-lua                    \
    lua-nginx-cookie                         \
    lua-nginx-dns                            \
    lua-nginx-string                         \
    lua-nginx-websocket                      \
    screen;                                  \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/

# Downloading the latest VSC Server release and extracting the release archive
RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-x64.tar.gz -O - 2>/dev/null|tar xzf -

# Creating the user and usergroup
RUN    groupadd --gid $USER_GID $USERNAME                   \
    && useradd --uid $USER_UID --gid $USERNAME -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL             \
        >> /etc/sudoers.d/$USERNAME                         \
    && echo ALL ALL=\(root\) NOPASSWD:ALL                   \ 
        >> /etc/sudoers.d/$USERNAME                         \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# This is just in the docker at build time
RUN chmod g+rw /home && \
    mkdir -p /home/workspace && \
    chown -R $USERNAME:$USERNAME /home/workspace && \
    chown -R $USERNAME:$USERNAME /home/${RELEASE_TAG}-linux-x64;

EXPOSE 3000
EXPOSE 4000-5000

# Those are set again in the entrypoint.sh wrapper script
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV HOME=/home/workspace
ENV EDITOR=code
ENV VISUAL=code
ENV GIT_EDITOR="code --wait"
ENV OPENVSCODE_SERVER_ROOT=/home/${RELEASE_TAG}-linux-x64

WORKDIR /

# Copy nginx config to support https and authentication
RUN wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${OAUTH_PROXY_RELEASE_TAG}/oauth2_proxy-${OAUTH_PROXY_RELEASE_TAG}.linux-amd64.go1.13.6.tar.gz -O - 2>/dev/null|(mkdir -p /opt/oauth2_proxy && cd /opt/oauth2_proxy && tar xzvf - && ln -s /opt/oauth2_proxy/* /opt/oauth2_proxy/oauth2_proxy)

# Condig/Website
COPY website/ /website/
COPY nginx.vscode.conf /etc/nginx/nginx.conf
RUN mv /website/imgs/favicon.ico /website/
RUN ls -la /website/*

# Copy wrapper and run that exec-style as entrypoint
COPY entrypoint.sh ${OPENVSCODE_SERVER_ROOT}/entrypoint.sh
ENTRYPOINT ["/bin/bash", "-c", "exec ${OPENVSCODE_SERVER_ROOT}/entrypoint.sh \"${@}\"", "--"]
