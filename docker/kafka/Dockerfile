FROM openjdk:8u121 as jdk
WORKDIR /opt
RUN wget http://archive.apache.org/dist/kafka/2.1.1/kafka_2.11-2.1.1.tgz &&\
    tar -zxvf kafka_2.11-2.1.1.tgz && \
    mv kafka_2.11-2.1.1 kafka
ADD run.sh kafka/bin
ENV PATH=${PATH}:/opt/kafka/bin
WORKDIR /opt/kafka
EXPOSE 9092
CMD ["run.sh"]