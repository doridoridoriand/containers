FROM centos:8

RUN dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install wget openssl openssl-devel readline readline-devel zlib zlib-devel sed net-tools traceroute lsof strace bind-utils man tree mailx sysstat dstat mlocate vim zsh tcpdump git tmux jq && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf -y update && \
    dnf install -y htop && \
    dnf -y install mysql postgresql ruby-devel && \
    dnf clean all

RUN cd /tmp && wget http://download.redis.io/redis-stable.tar.gz \
      && tar xvzf redis-stable.tar.gz \
      && cd redis-stable \
      && make \
      && cp src/redis-cli /usr/local/bin/ \
      && chmod 755 /usr/local/bin/redis-cli

RUN wget https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.0.tar.gz && tar -zxvf ruby-3.0.0.tar.gz
RUN cd ruby-3.0.0 && ./configure && make && make install
