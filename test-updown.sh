#!/bin/bash
set -eu -o pipefail
set -x

source .env

RANGE=192.168.1.0/24
# Parent
HOST_P=krill-root
# Child
HOST_C1=krill-host1

CA_PARENT=testbed
CA1=test1

TESTDIR=./TESTDIR

DATADIR=/var/krill/data

COMPOSE="docker compose"
EXEC="$COMPOSE exec -T -e KRILL_CLI_TOKEN=$KRILL_ADMIN_TOKEN"

mkdir $TESTDIR
cd $TESTDIR

$EXEC $HOST_P hostname
$EXEC $HOST_C1 hostname

CA_NAME=$($EXEC $HOST_C1 krillc show -c $CA1 -f json | jq -r .handle || :)
if [ -n "$CA_NAME" ]; then
    $EXEC $HOST_C1 krillc delete -c $CA1 || :
fi
$EXEC $HOST_C1 krillc add -c $CA1

PARENT_REQ=parent-req-${CA1}.xml
$EXEC $HOST_C1 krillc parents request -c $CA1 > $PARENT_REQ
$EXEC $HOST_P tee /tmp/$PARENT_REQ < $PARENT_REQ

CHILD_EXISTS=$($EXEC $HOST_P krillc show -c $CA_PARENT -f json | jq --arg arg $CA1 '.children | contains([$arg])')
if [ "$CHILD_EXISTS" = "true" ]; then
    # Error: Key/Value error: Store error: io error No such file or directory (os error 2) 対策
    $EXEC $HOST_P touch ${DATADIR}/status/testbed/children-${CA1}.json
    $EXEC $HOST_P krillc children remove -c $CA_PARENT --child $CA1 || :
fi
$EXEC $HOST_P krillc children add -c $CA_PARENT --child $CA1 -4 $RANGE --request /tmp/$PARENT_REQ

PARENT_RES=parent-res-${CA1}.xml
$EXEC $HOST_P krillc children response -c $CA_PARENT --child $CA1 > $PARENT_RES
$EXEC $HOST_C1 tee /tmp/$PARENT_RES < $PARENT_RES
$EXEC $HOST_C1 krillc parents add -c $CA1 --parent $CA_PARENT --response /tmp/$PARENT_RES

REPO_REQ=repo-req-${CA1}.xml
$EXEC $HOST_C1 krillc repo request -c $CA1 > $REPO_REQ
$EXEC $HOST_P tee /tmp/$REPO_REQ < $REPO_REQ

PUBLISHER_NAME=$($EXEC $HOST_P krillc pubserver publishers show --publisher $CA1 -f json | jq -r .handle || :)
if [ -n "$PUBLISHER_NAME" ]; then
    $EXEC $HOST_P krillc pubserver publishers remove --publisher $CA1 || :
fi
$EXEC $HOST_P krillc pubserver publishers add --request /tmp/$REPO_REQ

REPO_RES=repo-res-${CA1}.xml
$EXEC $HOST_P krillc pubserver publishers response --publisher $CA1 > $REPO_RES
$EXEC $HOST_C1 tee /tmp/$REPO_RES < $REPO_RES
$EXEC $HOST_C1 krillc repo configure -c $CA1 --response /tmp/$REPO_RES
$EXEC $HOST_C1 krillc repo show -c $CA1
$EXEC $HOST_C1 krillc repo status -c $CA1

sleep 5
$EXEC $HOST_C1 krillc show -c $CA1 -f json | jq .resources
