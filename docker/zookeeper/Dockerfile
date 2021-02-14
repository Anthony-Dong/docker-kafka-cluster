FROM openjdk:8-jdk as jdk

RUN apt-get update &&\
    apt-get install -y vim

WORKDIR /opt
RUN wget http://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz &&\
    tar -zxvf zookeeper-3.4.10.tar.gz &&\
    mv zookeeper-3.4.10 zookeeper &&\
    cp zookeeper/conf/zoo_sample.cfg zookeeper/conf/zoo.cfg

ENV PATH=${PATH}:/opt/zookeeper/bin
WORKDIR /opt/zookeeper
EXPOSE 2181
CMD ["/bin/bash","-c","zkServer.sh start-foreground"]