.PHONY: all image run zookeeper delete clean

all:stop run

ZK := zookeeper-01 zookeeper-02 zookeeper-03

image:
	make -C docker
run:
	docker-compose --compatibility up -d
zookeeper: stop
	docker-compose --compatibility up -d $(ZK)
stop:
	docker-compose --compatibility stop
delete:
	docker-compose --compatibility down
clean: delete
	$(RM) -r \
	kafka-01/data \
	kafka-02/data \
	kafka-03/data \

upper:
	@echo $(shell echo $(subst .,_,$(str))| tr a-z A-Z)