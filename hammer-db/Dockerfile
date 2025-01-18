FROM doridoridoriand/lifeboat-ubuntu:latest

WORKDIR /tmp

RUN wget https://github.com/TPC-Council/HammerDB/releases/download/v4.12/HammerDB-4.12-Linux.tar.gz
RUN tar -zxvf HammerDB-4.12-Linux.tar.gz
RUN cd /tmp/HammerDB-4.12 && mv hammerdbcli /usr/bin/hammerdbcli

CMD ["/usr/bin/hammerdbcli"]