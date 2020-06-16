FROM ubuntu:eoan

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
    jq

RUN wget https://az764295.vo.msecnd.net/stable/a5d1cc28bb5da32ec67e86cc50f84c67cc690321/code_1.46.0-1591780013_amd64.deb && apt-get -y install ./code_1.46.0-1591780013_amd64.deb

RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
      wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && apt update && \
      apt-get -y install google-chrome-stable

CMD /bin/bash
