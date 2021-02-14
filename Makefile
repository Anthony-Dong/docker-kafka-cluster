all:stop run
image:
	make -C docker
run:
	docker-compose --compatibility up -d
stop:
	docker-compose --compatibility stop
delete:
	docker-compose --compatibility down
clean: delete
	$(RM) -r zookeeper-01/data/version-2 \
	zookeeper-02/data/version-2 \
	zookeeper-03/data/version-2 \
	kafka-01/logs kafka-01/kafka-logs \
	kafka-02/logs kafka-02/kafka-logs \
	kafka-03/logs kafka-03/kafka-logs \
	