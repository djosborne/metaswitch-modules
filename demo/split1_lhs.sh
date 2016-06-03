#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

run "while true; do \\
docker exec mesoscni_client_1 curl  --connect-timeout 1 -s frontend.marathon.mesos && echo || echo \"(timeout)\"; \\
        sleep 1; \\
    done \\
    "
