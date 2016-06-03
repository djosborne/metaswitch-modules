#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

export MARATHON_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mesoscni_marathon_1)
export ETCD_AUTHORITY=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mesoscni_etcd_1):2379

desc "Our application uses a redis database."
desc "Lets define a marathon application for one"
run "cat $(relative database.json)"

desc "Lets launch it using Marathon"
run "curl -X POST -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps -d @$(relative database.json)"
desc ""

desc "Next, let's write our application: a Python flask app that uses redis as its database"
run "cat $(relative app.py)"

desc "Let's wrap our app into a marathon application definition"
run "cat $(relative frontend.json)"

desc "Then launch it using Marathon"
run "curl -X POST -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps -d @$(relative frontend.json)"
desc ""

desc "Let's check how Mesos DNS responds to queries for our frontend service"
run "docker exec mesoscni_slave_1 nslookup frontend.marathon.mesos"

desc "...and now the backend"
run "docker exec mesoscni_slave_1 nslookup database.marathon.mesos"

tmux new -d -s my-session-2 \
    "$(dirname ${BASH_SOURCE})/split1_lhs.sh" \; \
    split-window -h -d "sleep 10; $(dirname $BASH_SOURCE)/split1_rhs.sh" \; \
    attach \;
