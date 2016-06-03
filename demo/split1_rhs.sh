#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

desc "I can access the frontend"
run "echo '<----- see left pane'"
desc "But I can also access redis"
run "docker exec mesoscni_client_1 docker run --rm redis:alpine redis-cli -h database.marathon.mesos -p 6379 SET hits 0"

desc "This is bad news, so lets add some policy"

desc "Let's define a policy that only allows redis to accept inbound connections from the frontend"
run "cat $(relative redis-policy.yaml)"
run "./calicoctl create --filename=./redis-policy.yaml"

desc "Our frontend policy will need to accept connections from anywhere, but only outbound connect to redis"
run "cat $(relative frontend-policy.yaml)"
run "./calicoctl create --filename=./frontend-policy.yaml"

desc "We can no longer access redis directly - only the frontend can"
run "docker exec mesoscni_client_1 docker run --rm redis:alpine redis-cli -h database.marathon.mesos -p 6379 SET hits 0"

