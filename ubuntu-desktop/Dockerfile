FROM ubuntu:jammy-20231128

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install build-essential

RUN apt-get -y install wget \
    curl \
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
    ubuntu-desktop

CMD /bin/bash
