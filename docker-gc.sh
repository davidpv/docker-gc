#!/bin/bash

DOCKER=${DOCKER:=docker}
DRY_RUN=${DRY_RUN:=false}
EXCLUDE_IMAGES=${EXCLUDE_IMAGES:=}
EXCLUDE_CONTAINERS=${EXCLUDE_CONTAINERS:=}
PID_DIR=${PID_DIR:=/var/run}

for pid in $(pidof -s docker-gc); do
    if [[ $pid != $$ ]]; then
        echo "[$(date)] : docker-gc : Process is already running with PID $pid"
        exit 1
    fi
done
trap "rm -f -- '$PID_DIR/dockergc'" EXIT
echo $$ > $PID_DIR/dockergc


$DOCKER ps -a
echo "STOPING CONTAINERS"
$DOCKER stop $($DOCKER ps -a | grep -v docker-gc | awk 'FNR > 1 {print $1}') 2>/dev/null
echo "DELETING CONTAINERS"
$DOCKER rm --force $($DOCKER ps -a | docker-gc | awk 'FNR > 1 {print $1}') >/dev/null
echo "IMAGES TO DELETE"
$DOCKER images -a | tail -n+2  |sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}"
echo "DELETING IMAGES"
$DOCKER rmi --force $($DOCKER images -a  | tail -n+2 | sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}"|  cut -d' ' -f3) 2>/dev/null
