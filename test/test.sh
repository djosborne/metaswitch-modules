#!/bin/bash
docker-compose up -d

export IP_ADDRESS=`docker inspect --format='{{.NetworkSettings.IPAddress}}' metaswitchmodules_marathon_1`
echo $IP_ADDRESS

# put tar.gz somewhere
# load json
function sendjson() {
	curl --retry-delay 2 --retry 10 -X POST http://$IP_ADDRESS:8080/v2/apps -d @./sjc-static.json -H "Content-type: application/json"
}

COUNTER=5
sendjson
until [ $COUNTER -eq 0 ]; do
	echo $COUNTER
	sendjson
	if [ $? -eq 0 ]; then
		break
	fi
	let COUNTER-=1
	sleep 2
done
