FROM python:3.9.16-alpine3.17

COPY mailrelaytest.sh /mailrelaytest.sh
RUN chmod 0700 /mailrelaytest.sh
RUN apk update && apk upgrade --available && sync
RUN apk add busybox-extras
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
    postgresql-client \
    pv \
    sysstat \
    tcpdump \
    tcpflow \
    tree \
    vim
ENTRYPOINT bash