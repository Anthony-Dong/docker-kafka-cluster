## Kafka 的本地Docker集群

### 项目目录
```shell
➜  docker git:(master) ✗ tree -L 1
➜  kafka git:(master) ✗ tree -L 2
.
├── Makefile
├── docker
│   ├── Makefile
│   ├── README.md
│   ├── kafka
│   └── zookeeper
├── docker-compose.yml
├── kafka-01
│   ├── config
│   ├── kafka-logs
│   └── log
├── kafka-02
│   ├── config
│   ├── kafka-logs
│   └── log
├── kafka-03
│   ├── config
│   ├── kafka-logs
│   └── log
└── zookeeper-01
    ├── conf
    └── data
```
### 构建基础镜像
进入docker目录执行
```shell
➜  docker git:(master) ✗ make
docker build -t kafka:2.1.1 ./kafka
Sending build context to Docker daemon  44.54kB
Step 1/8 : FROM openjdk:8u121 as jdk
 ---> 9766c638ae8e
Step 2/8 : WORKDIR /opt
 ---> Using cache
 ---> cc867e6c259d
Step 3/8 : RUN wget http://archive.apache.org/dist/kafka/2.1.1/kafka_2.11-2.1.1.tgz &&    tar -zxvf kafka_2.11-2.1.1.tgz &&     mv kafka_2.11-2.1.1 kafka
 ---> Using cache
 ---> fac62ffcf4c5
Step 4/8 : ADD run.sh kafka/bin
 ---> Using cache
 ---> 1b9e2b9218d4
Step 5/8 : ENV PATH=${PATH}:/opt/kafka/bin
 ---> Using cache
 ---> 87f56cdd5b1f
Step 6/8 : WORKDIR /opt/kafka
 ---> Using cache
 ---> 8dd5ea7f99ed
Step 7/8 : EXPOSE 9092
 ---> Using cache
 ---> 28f6a61c9c1e
Step 8/8 : CMD ["run.sh"]
 ---> Using cache
 ---> b0738857de0d
Successfully built b0738857de0d
Successfully tagged kafka:2.1.1
docker build -t zookeeper:3.4.10 ./zookeeper
Sending build context to Docker daemon  9.728kB
Step 1/8 : FROM openjdk:8u121 as jdk
 ---> 9766c638ae8e
Step 2/8 : WORKDIR /opt
 ---> Using cache
 ---> cc867e6c259d
Step 3/8 : RUN wget http://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz &&    tar -zxvf zookeeper-3.4.10.tar.gz &&    mv zookeeper-3.4.10 zookeeper &&    cp zookeeper/conf/zoo_sample.cfg zookeeper/conf/zoo.cfg
 ---> Using cache
 ---> d8e81171f81c
Step 4/8 : ADD run.sh zookeeper/bin
 ---> Using cache
 ---> 4a6ab8125054
Step 5/8 : ENV PATH=${PATH}:/opt/zookeeper/bin
 ---> Using cache
 ---> 331ff425edb8
Step 6/8 : WORKDIR /opt/zookeeper
 ---> Using cache
 ---> 35a2c21ac275
Step 7/8 : EXPOSE 2181
 ---> Using cache
 ---> 37723ee06ef0
Step 8/8 : CMD [ "run.sh" ]
 ---> Using cache
 ---> 5242b4b9f635
Successfully built 5242b4b9f635
Successfully tagged zookeeper:3.4.10
```


### 运行kafka3节点集群
1、记得网卡IP的IP需要修改一下，比如`kafka-02/config/server.properties`文件，修改`advertised.listeners=PLAINTEXT://172.15.64.10:9092`,我的本地网卡的IP是`172.15.64.10`，暴露的这台机器地址的IP是9092,切记其他节点不一定是这个。
具体原因是：
```shell
[zk: localhost:2181(CONNECTED) 13] get /brokers/ids/1
{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://172.15.64.10:9091"],"jmx_port":-1,"host":"172.15.64.10","timestamp":"1611906107097","port":9091,"version":4}
```

2、运行kakfa集群
```shell
➜  kafka git:(master) ✗ make
docker-compose stop
Stopping kafka_kafka-02_1     ... done
Stopping kafka_kafka-03_1     ... done
Stopping kafka_kafka-01_1     ... done
Stopping kafka_zookeeper-01_1 ... done
docker-compose up -d
Recreating kafka_kafka-01_1     ... done
Recreating kafka_kafka-03_1     ... done
Recreating kafka_zookeeper-01_1 ... done
Recreating kafka_kafka-02_1     ... done
```

### 客户端连接信息
1、容器内部broker节点：`kafka-01:9092,kafka-02:9092,kafka-03:9092` ，相当于内网IP

2、容器外部broker节点：`localhost:9091,localhost:9092,localhost:9093` 相当于公网IP

3、容器内部Zk节点：`zookeeper-01:2181`

4、容器外部Zk节点：`localhost:2181`