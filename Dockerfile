FROM python:3.13-alpine3.21

COPY mailrelaytest.sh /mailrelaytest.sh
COPY mailrelaytest-tls.sh /mailrelaytest-tls.sh
RUN chmod 0700 /mailrelaytest.sh && chmod 0700 /mailrelaytest-tls.sh
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
CMD ["bash"]