#!/bin/bash
cd $(dirname $(realpath $0))
source ./test-common.sh

export https_proxy=http://${SQUID_ADDR_PORT}
KRILL_CLI_TOKEN=$KRILL_ADMIN_TOKEN
CURL_INSECURE=1
source ./lib-krill-curl.sh

type jq

cd $TESTDIR

URL_P="https://root.${DOMAIN}:${KRILL_PORT:-3000}/"
URL_C1="https://host1.${DOMAIN}:${KRILL_PORT:-3000}/"

#$EXEC $HOST_P krillc roas list -c $CA_PARENT --api
krillcurl_roas_list $URL_P $CA_PARENT | jq .

#$EXEC $HOST_C1 krillc roas list -c $CA1 --api
krillcurl_roas_list $URL_C1 $CA1 | jq .

#ROA_DEF="192.168.1.0/24-25 => 64496"
#$EXEC $HOST_C1 krillc roas update -c $CA1 --remove "$ROA_DEF" --api
krillcurl_roas_update_remove $URL_C1 $CA1 "192.168.1.0/24" 25 64496 ||:
krillcurl_roas_list $URL_C1 $CA1 | jq .

#$EXEC $HOST_C1 krillc roas update -c $CA1 --add "$ROA_DEF" --api
krillcurl_roas_update_add $URL_C1 $CA1 "192.168.1.0/24" 25 64496 "comment test" | jq .
krillcurl_roas_list $URL_C1 $CA1 | jq .

#TODO
$EXEC $HOST_C1 krillc roas bgp suggest -c $CA1 --api
$EXEC $HOST_C1 krillc roas bgp analyze -c $CA1 --api
