FROM python:3.9-alpine3.14
RUN apk add --no-cache \
    atop \
    bash \
    bash-completion \
    bind-tools \
    build-base \
    ca-certificates \
    curl \
    git \
    htop \
    iftop \
    iotop \
    iperf \
    iputils \
    jq \
    mtr \
    net-tools \
    netcat-openbsd \
    nfs-utils \
    ngrep \
    nmap \
    openssl \
    pv \
    sysstat \
    tcpdump \
    tcpflow \
    tree \
    vim
ENTRYPOINT bash