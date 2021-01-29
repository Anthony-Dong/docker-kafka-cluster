all:stop run
run:
	docker-compose up -d
stop:
	docker-compose stop
clean:
	$(RM) -r kafka-03/log kafka-02/log kafka-01/log kafka-03/kafka-logs kafka-02/kafka-logs kafka-01/kafka-logs zookeeper-01/data