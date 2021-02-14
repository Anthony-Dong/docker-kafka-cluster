## Kafka&&zookeeper 的本地Docker集群
### 版本
-  kafka:2.1.1
- zookeeper:3.4.0

>   不使用 docker-compose 来build Dockerfile的原因是无法复用一个image，导致镜像过多，所以需要构建本地镜像，然后再启动docker-compose，由于docker-compose本地环境无法限制内存，可以参考[官方文档](https://docs.docker.com/compose/compose-file/compose-file-v3/#resources)，需要启动添加`--compatibility` 参数

- 3zk集群+3kafka集群（zk集群依赖于myid文件，所以依赖volume形式捆绑）
- 内存限制，zk 256M, kafka 512M， 由于swap的内存，都会*2。

### 项目目录
```shell
➜  kafka-cluster git:(master) ✗ tree -L 2
.
├── Makefile
├── README.md
├── docker
│   ├── Makefile
│   ├── kafka
│   └── zookeeper
├── docker-compose.yml
├── kafka-01
│   └── config
├── kafka-02
│   └── config
├── kafka-03
│   └── config
├── zookeeper-01
│   ├── conf
│   └── data
├── zookeeper-02
│   ├── conf
│   └── data
└── zookeeper-03
    ├── conf
    └── data

18 directories, 4 files
```
### 构建基础镜像
1、进入docker目录执行
```shell
➜  kafka-cluster git:(master) ✗ make image 
make -C docker
docker build -t kafka:2.1.1 ./kafka
Sending build context to Docker daemon  43.52kB
Step 1/8 : FROM openjdk:8-jdk as jdk
 ---> 8ca4a86e32d8
Step 2/8 : RUN apt-get update &&    apt-get install -y vim
 ---> Using cache
 ---> efcdcb5b5552
Step 3/8 : WORKDIR /opt
 ---> Using cache
 ---> 19e7642d6a49
Step 4/8 : RUN wget http://archive.apache.org/dist/kafka/2.1.1/kafka_2.11-2.1.1.tgz &&    tar -zxvf kafka_2.11-2.1.1.tgz &&     mv kafka_2.11-2.1.1 kafka
 ---> Using cache
 ---> 9d14fadc629a
Step 5/8 : ENV PATH=${PATH}:/opt/kafka/bin
 ---> Using cache
 ---> 4caabda44388
Step 6/8 : WORKDIR /opt/kafka
 ---> Using cache
 ---> f3d17a4fc969
Step 7/8 : EXPOSE 9092 9999
 ---> Using cache
 ---> a6e1033c7fe3
Step 8/8 : CMD ["/bin/bash","-c","JMX_PORT=9999 kafka-server-start.sh config/server.properties"]
 ---> Using cache
 ---> 7b9bf48f130f
Successfully built 7b9bf48f130f
Successfully tagged kafka:2.1.1
docker build -t zookeeper:3.4.10 ./zookeeper
Sending build context to Docker daemon  8.704kB
Step 1/8 : FROM openjdk:8-jdk as jdk
 ---> 8ca4a86e32d8
Step 2/8 : RUN apt-get update &&    apt-get install -y vim
 ---> Using cache
 ---> efcdcb5b5552
Step 3/8 : WORKDIR /opt
 ---> Using cache
 ---> 19e7642d6a49
Step 4/8 : RUN wget http://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz &&    tar -zxvf zookeeper-3.4.10.tar.gz &&    mv zookeeper-3.4.10 zookeeper &&    cp zookeeper/conf/zoo_sample.cfg zookeeper/conf/zoo.cfg
 ---> Using cache
 ---> 4cbdebd3089f
Step 5/8 : ENV PATH=${PATH}:/opt/zookeeper/bin
 ---> Using cache
 ---> d6f211f64f95
Step 6/8 : WORKDIR /opt/zookeeper
 ---> Using cache
 ---> e44cbf4eaba6
Step 7/8 : EXPOSE 2181
 ---> Using cache
 ---> de02f66a44d5
Step 8/8 : CMD ["/bin/bash","-c","zkServer.sh start-foreground"]
 ---> Using cache
 ---> a3638609cfd4
Successfully built a3638609cfd4
Successfully tagged zookeeper:3.4.10
```


### 运行kafka集群
1、记得网卡IP的IP需要修改一下，比如`kafka-02/config/server.properties`文件，修改`advertised.listeners=PLAINTEXT://172.15.64.10:9092`,我的本地网卡的IP是`172.15.64.10`，暴露的这台机器地址的IP是9092,切记其他节点不一定是这个。
具体原因是：

```shell
[zk: localhost:2181(CONNECTED) 13] get /brokers/ids/1
{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://172.15.64.10:9091"],"jmx_port":-1,"host":"172.15.64.10","timestamp":"1611906107097","port":9091,"version":4}
```

2、运行kakfa集群
```shell
➜  kafka-cluster git:(master) ✗ make 
docker-compose --compatibility stop
docker-compose --compatibility up -d
Creating network "kafka-cluster_default" with the default driver
Creating kafka-cluster_kafka-03_1     ... done
Creating kafka-cluster_zookeeper-01_1 ... done
Creating kafka-cluster_kafka-02_1     ... done
Creating kafka-cluster_kafka-01_1     ... done
Creating kafka-cluster_zookeeper-03_1 ... done
Creating kafka-cluster_zookeeper-02_1 ... done
```

2、只运行zk集群

```shell
➜  kafka-cluster git:(master) ✗ make zookeeper
docker-compose --compatibility stop
docker-compose --compatibility up -d zookeeper-01 zookeeper-02 zookeeper-03
Creating network "kafka-cluster_default" with the default driver
Creating kafka-cluster_zookeeper-01_1 ... done
Creating kafka-cluster_zookeeper-03_1 ... done
Creating kafka-cluster_zookeeper-02_1 ... done
```

 查看集群信息,可以看到` myid`大的被选举为leader

```shell
➜  ~ docker exec -it kafka-cluster_zookeeper-01_1 zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /opt/zookeeper/bin/../conf/zoo.cfg
Mode: follower
➜  ~ docker exec -it kafka-cluster_zookeeper-02_1 zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /opt/zookeeper/bin/../conf/zoo.cfg
Mode: follower
➜  ~ docker exec -it kafka-cluster_zookeeper-03_1 zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /opt/zookeeper/bin/../conf/zoo.cfg
Mode: leade
```



### 客户端连接信息

1、容器内部broker节点：`kafka-01:9092,kafka-02:9092,kafka-03:9092` ，相当于内网IP

2、容器外部broker节点：`localhost:9091,localhost:9092,localhost:9093` 相当于公网IP

3、容器内部Zk节点集群：`zookeeper-01:2181,zookeeper-02:2181,zookeeper-03:2181`

4、容器外部Zk节点集群：`localhost:2181,localhost:2182,localhost:2183`