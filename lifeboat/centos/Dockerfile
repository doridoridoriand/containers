FROM quay.io/centos/centos:stream10 AS ruby-builder

ENV TZ=Asia/Tokyo
ENV RUBY_VERSION=3.4.12
ENV RUBY_SHA256=5e5d85ad93b0adcccbad47733680f4892bd0078e3342437f7babce01c1872479

RUN dnf -y distro-sync && \
    dnf -y update && \
    dnf -y install dnf-plugins-core && \
    dnf -y config-manager --set-enabled crb && \
    dnf -y install gcc make wget openssl openssl-devel readline readline-devel zlib zlib-devel libyaml-devel tar gzip

RUN cd /tmp && \
    wget "https://cache.ruby-lang.org/pub/ruby/3.4/ruby-${RUBY_VERSION}.tar.gz" && \
    echo "${RUBY_SHA256}  ruby-${RUBY_VERSION}.tar.gz" | sha256sum --check && \
    tar -zxvf ruby-${RUBY_VERSION}.tar.gz && \
    cd ruby-${RUBY_VERSION} && \
    ./configure --prefix=/usr/local && \
    make install && \
    cd /tmp && \
    rm -rf ruby-${RUBY_VERSION}* && \
    dnf clean all

FROM quay.io/centos/centos:stream10

ENV TZ=Asia/Tokyo

COPY --from=ruby-builder /usr/local /usr/local

RUN dnf -y distro-sync && \
    dnf -y update && \
    dnf -y groupinstall "Development Tools" && \
    dnf -y install wget openssl openssl-devel readline readline-devel zlib zlib-devel gcc sed net-tools iputils traceroute lsof strace bind-utils man tree s-nail sysstat dstat plocate vim zsh tcpdump git tmux jq libyaml && \
    dnf install -y --allowerasing curl && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm && \
    dnf -y update && \
    dnf install -y htop valkey cowsay && \
    dnf -y install mariadb postgresql && \
    dnf clean all
