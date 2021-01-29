#!/bin/bash
kafka-server-start.sh -daemon config/server.properties
while true;do echo kafka is running;sleep 10;done