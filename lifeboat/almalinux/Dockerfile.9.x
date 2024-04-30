FROM almalinux:9.3

RUN dnf -y distro-sync && dnf -y update && dnf -y groupinstall "Development Tools"

RUN dnf -y install wget \
    openssl \
    openssl-devel \
    readline \
    readline-devel \
    zlib \
    zlib-devel \
    gcc \
    sed \
    net-tools \
    traceroute \
    lsof \
    strace \
    bind-utils \
    man \
    tree \
    s-nail \
    sysstat \
    dstat \
    mlocate \
    vim \
    zsh \
    tcpdump \
    git \
    tmux \
    jq

RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
      && dnf -y update && dnf install -y htop

RUN dnf -y install mysql postgresql

#RUN wget http://download.redis.io/redis-stable.tar.gz \
#      && tar xvzf redis-stable.tar.gz \
#      && cd redis-stable \
#      && make distclean \
#      && make \
#      && cp src/redis-cli /usr/local/bin/ \
#      && chmod 755 /usr/local/bin/redis-cli

RUN dnf clean all
