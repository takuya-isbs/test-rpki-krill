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
