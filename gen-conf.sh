#!/bin/bash
set -eu
set -x

source .env

DATADIR_LIST="
SHARE
data-root
data-host1
data-host2
"

for d in $DATADIR_LIST; do
    mkdir -p $d
    chown ${RUN_USER_UID}:${RUN_USER_GID} $d
done

CONF_LIST="
conf/krill-root.conf
conf/krill-host1.conf
conf/krill-host2.conf
"

for conf in $CONF_LIST; do
    sed -e "s/@DOMAIN@/${DOMAIN}/" \
        -e "s/@PORT@/${KRILL_PORT}/" \
        ${conf}.tmpl > ${conf}
done
