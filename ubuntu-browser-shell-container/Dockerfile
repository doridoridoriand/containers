FROM doridoridoriand/lifeboat-ubuntu:noble-1735639823

# Pin ttyd version for security and reproducibility
ARG TTYD_VERSION=1.7.3

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        git \
        libjson-c-dev \
        libwebsockets-dev && \
    git clone --branch $TTYD_VERSION https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake .. && make && make install && \
    cd / && \
    apt-get purge -y build-essential cmake git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /ttyd

# Create non-root user
RUN useradd -m -s /bin/bash shelluser
USER shelluser
WORKDIR /home/shelluser

EXPOSE 7681

# Add any necessary restrictions to the shell
CMD ["ttyd", "-p", "7681", "--writable", "bash", "-l"]