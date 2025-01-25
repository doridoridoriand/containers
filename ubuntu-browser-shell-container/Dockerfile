FROM doridoridoriand/lifeboat-ubuntu:noble-1735639823

RUN apt-get update
RUN apt-get install -y build-essential cmake git libjson-c-dev libwebsockets-dev
RUN git clone https://github.com/tsl0922/ttyd.git
RUN cd ttyd && mkdir build && cd build && cmake .. && make && make install

EXPOSE 7681

CMD ["ttyd", "-p", "7681", "--writable", "bash"]