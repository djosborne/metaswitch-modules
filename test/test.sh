#!/bin/bash
docker-compose up -d

export IP_ADDRESS=`docker inspect --format='{{.NetworkSettings.IPAddress}}' metaswitchmodules_marathon_1`
# Wait for the marathon container to come up
sleep 10
curl -X POST http://$IP_ADDRESS:8080/v2/apps -d @$0/sjc-static.json -H "Content-type: application/json"
docker exec metaswitchmodules_slave1_1 ping -c 4 192.168.0.2
