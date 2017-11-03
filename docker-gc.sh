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

echo " === DOCKER CONTAINERS === "
$DOCKER ps -a

echo " === STOPING CONTAINERS === "
if [[ "$DRY_RUN" = "true" ]]
then
    echo "DRY RUN: $DOCKER stop $($DOCKER ps -a | grep -v docker-gc |  grep -v -E "${EXCLUDE_CONTAINERS// /|}" | awk 'FNR > 1 {print $1}') 2>/dev/null"
else
    echo "DRY RUN: $DOCKER stop $($DOCKER ps -a | grep -v docker-gc |  grep -v -E "${EXCLUDE_CONTAINERS// /|}" | awk 'FNR > 1 {print $1}') 2>/dev/null"
    $DOCKER stop $($DOCKER ps -a | grep -v docker-gc |  grep -v -E "${EXCLUDE_CONTAINERS// /|}" | awk 'FNR > 1 {print $1}') 2>/dev/null
fi

echo " === DELETING CONTAINERS === "
if [[ "$DRY_RUN" = "true" ]]
then
    echo "DRY RUN: $DOCKER rm --force $($DOCKER ps -a | grep -v docker-gc |  grep -v -E ${EXCLUDE_CONTAINERS// /|} | awk 'FNR > 1 {print $1}') >/dev/null"
else
    echo "DRY RUN: $DOCKER rm --force $($DOCKER ps -a | grep -v docker-gc |  grep -v -E "${EXCLUDE_CONTAINERS// /|}" | awk 'FNR > 1 {print $1}') >/dev/null"
    $DOCKER rm --force $($DOCKER ps -a | grep -v docker-gc |  grep -v -E "${EXCLUDE_CONTAINERS// /|}" | awk 'FNR > 1 {print $1}') >/dev/null
fi

echo " === IMAGES TO DELETE === "
if [[ "$DRY_RUN" = "true" ]]
then
    echo "$DOCKER images -a | tail -n+2  |sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}""
else
    echo "DRY RUN: $DOCKER images -a | tail -n+2  |sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}""
    $DOCKER images -a | tail -n+2  |sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}"
fi


echo " === DELETING IMAGES === "
if [[ "$DRY_RUN" = "true" ]]
then
    echo "DRY RUN: $DOCKER rmi --force $($DOCKER images -a  | tail -n+2 | sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}"|  cut -d' ' -f3) 2>/dev/null"
else
    echo "DRY RUN: $DOCKER rmi --force $($DOCKER images -a  | tail -n+2 | sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}"|  cut -d' ' -f3) 2>/dev/null"
    $DOCKER rmi --force $($DOCKER images -a  | tail -n+2 | sed 's/^\([^ ]*\) *\([^ ]*\) *\([^ ]*\).*/ \1:\2 \3 /' | grep -v -E "${EXCLUDE_IMAGES// /|}"|  cut -d' ' -f3) 2>/dev/null
fi
