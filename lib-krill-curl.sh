KRILL_API_PREFIX=api/v1

: $KRILL_CLI_TOKEN

CURL_INSECURE=${CURL_INSECURE:-0}

krillcurl() {
    local headers=()
    local options=()
    headers+=("-H" "Authorization: Bearer ${KRILL_CLI_TOKEN}")
    if [ $CURL_INSECURE -eq 1 ]; then
        options+=("-k")
    fi
    options+=("--no-progress-meter")
    curl "${headers[@]}" "${options[@]}" "$@"
}

krillcurl_post() {
    local headers=("-X" "POST" "-d" "@-")
    headers+=("-H" "Content-Type: application/json")
    krillcurl "${headers[@]}" "$@"
}

krillcurl_roas_list() {
    local url="$1"
    local caname="$2"
    local apiurl="${1%/}/${KRILL_API_PREFIX}/cas/${caname}/routes"
    krillcurl "$apiurl"
}

krillcurl_roas_update_add() {
    local url="$1"
    local caname="$2"
    local prefix="$3"
    local max_length="$4"
    local asn="$5"
    local comment="$6"
    local apiurl="${1%/}/${KRILL_API_PREFIX}/cas/${caname}/routes"
    if [ "$comment" != null ]; then
        comment="\"${comment}\""
    fi
    krillcurl_post "$apiurl"  <<EOF
{
  "added": [
    {
      "asn": ${asn},
      "prefix": "${prefix}",
      "max_length": ${max_length},
      "comment": ${comment}
    }
  ],
  "removed": []
}
EOF
}

krillcurl_roas_update_remove() {
    local url="$1"
    local caname="$2"
    local prefix="$3"
    local max_length="$4"
    local asn="$5"
    local apiurl="${1%/}/${KRILL_API_PREFIX}/cas/${caname}/routes"
    krillcurl_post "$apiurl"  <<EOF
{
  "added": [],
  "removed": [
    {
      "asn": ${asn},
      "prefix": "${prefix}",
      "max_length": ${max_length}
    }
  ]
}
EOF
}
