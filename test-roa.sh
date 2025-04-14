#!/bin/bash
cd $(dirname $(realpath $0))
source ./test-common.sh

cd $TESTDIR

$EXEC $HOST_P hostname
$EXEC $HOST_C1 hostname

$EXEC $HOST_P krillc roas list -c $CA_PARENT
$EXEC $HOST_C1 krillc roas list -c $CA1

ROA_DEF="192.168.1.0/24-25 => 64496"
$EXEC $HOST_C1 krillc roas update -c $CA1 --remove "$ROA_DEF" || :
$EXEC $HOST_C1 krillc roas update -c $CA1 --add "$ROA_DEF"

$EXEC $HOST_C1 krillc roas list -c $CA1
#$EXEC $HOST_C1 krillc roas update -c $CA1 --remove "$ROA_DEF"

#$EXEC $HOST_P krillc roas bgp suggest -c $CA_PARENT

$EXEC $HOST_C1 krillc roas bgp suggest -c $CA1
$EXEC $HOST_C1 krillc roas bgp analyze -c $CA1
