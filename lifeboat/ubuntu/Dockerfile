FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install build-essential && apt-get -y install tzdata

RUN apt-get -y install wget \
    sed \
    net-tools \
    traceroute \
    lsof \
    strace \
    man \
    tree \
    sysstat \
    dstat \
    mlocate \
    vim \
    zsh \
    tcpdump \
    git \
    tmux \
    jq \
    htop \
    postgresql \
    mysql-client \
    redis
