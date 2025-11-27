FROM almalinux:9.4

RUN dnf -y distro-sync && \
    dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install wget openssl openssl-devel readline readline-devel zlib zlib-devel gcc sed net-tools traceroute lsof strace bind-utils man tree s-nail sysstat dstat mlocate vim zsh tcpdump git tmux jq && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf -y update && \
    dnf install -y htop && \
    dnf -y install mysql postgresql && \
    dnf clean all

#RUN wget http://download.redis.io/releases/redis-6.2.5.tar.gz \
#      && tar xvzf redis-6.2.5.tar.gz \
#      && cd redis-6.2.5 \
#      && make distclean \
#      && make \
#      && cp src/redis-cli /usr/local/bin/ \
#      && chmod 755 /usr/local/bin/redis-cli
