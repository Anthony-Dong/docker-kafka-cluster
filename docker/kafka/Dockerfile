FROM openjdk:8-jdk as jdk

RUN apt-get update &&\
    apt-get install -y vim

WORKDIR /opt
RUN wget http://archive.apache.org/dist/kafka/2.1.1/kafka_2.11-2.1.1.tgz &&\
    tar -zxvf kafka_2.11-2.1.1.tgz && \
    mv kafka_2.11-2.1.1 kafka

ENV PATH=${PATH}:/opt/kafka/bin
WORKDIR /opt/kafka
ENV JMX_PORT=9999
EXPOSE 9092 ${JMX_PORT}
CMD ["/bin/bash","-c","JMX_PORT=${JMX_PORT} kafka-server-start.sh config/server.properties"]