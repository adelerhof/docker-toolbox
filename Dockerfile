FROM python:3.13-alpine3.24

COPY mailrelaytest.sh /mailrelaytest.sh
COPY mailrelaytest-tls.sh /mailrelaytest-tls.sh
RUN chmod 0700 /mailrelaytest.sh && chmod 0700 /mailrelaytest-tls.sh
RUN apk update && apk upgrade --available && sync
# pip is not needed in the toolbox; its vendored libraries (urllib3, msgpack,
# setuptools) are what image scanners flag.
RUN python3 -m pip uninstall -y pip
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
    sslscan \
    tcpdump \
    tcpflow \
    tree \
    vim
CMD ["bash"]