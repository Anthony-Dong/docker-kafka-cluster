FROM openjdk:8u121 as jdk
WORKDIR /opt
RUN wget http://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz &&\
    tar -zxvf zookeeper-3.4.10.tar.gz &&\
    mv zookeeper-3.4.10 zookeeper &&\
    cp zookeeper/conf/zoo_sample.cfg zookeeper/conf/zoo.cfg 
ADD run.sh zookeeper/bin
ENV PATH=${PATH}:/opt/zookeeper/bin
WORKDIR /opt/zookeeper
EXPOSE 2181
CMD [ "run.sh" ]