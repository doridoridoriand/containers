FROM doridoridoriand/lifeboat-ubuntu:noble-1735639823

RUN apt-get update
RUN apt-get install -y build-essential cmake git libjson-c-dev libwebsockets-dev
RUN git clone https://github.com/tsl0922/ttyd.git
RUN cd ttyd && mkdir build && cd build && cmake .. && make && make install

# Create non-root user
RUN useradd -m -s /bin/bash shelluser
USER shelluser
WORKDIR /home/shelluser

EXPOSE 7681

# Add any necessary restrictions to the shell
CMD ["ttyd", "-p", "7681", "--writable", "bash", "-l"]