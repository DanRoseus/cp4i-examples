#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2020. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

DEBUG=false

NAMESPACE=dan
PRODUCT=swagger-1c
RELEASE=ademo

client_id="599b7aef-8841-4ee2-88a0-84d49c4d6ff2"
client_secret="0ea28423-e73b-47d4-b40e-ddb45c48bb0c"
realm=provider/default-idp-2
username=cp4i-admin
password=engageibmAPI1
ORG=main-demo
CATALOG=main-demo-catalog

TICK="\xE2\x9C\x85"
CROSS="\xE2\x9D\x8C"
JQ=jq

PLATFORM_API_EP=$(oc get route -n $NAMESPACE ${RELEASE}-mgmt-platform-api -o jsonpath="{.spec.host}")
[[ -z $PLATFORM_API_EP ]] && echo -e "[ERROR] ${CROSS} APIC platform api route doesn't exit" && exit 1
$DEBUG && echo "[DEBUG] PLATFORM_API_EP=${PLATFORM_API_EP}"

OUTPUT=""
function handle_res() {
  local body=$1
  local status=$(echo ${body} | $JQ -r ".status")
  $DEBUG && echo "[DEBUG] res body: ${body}"
  $DEBUG && echo "[DEBUG] res status: ${status}"
  if [[ $status == "null" ]]; then
    OUTPUT="${body}"
  elif [[ $status == "400" ]]; then
    if [[ $body == *"already exists"* || $body == *"already subscribed"* ]]; then
      OUTPUT="${body}"
      echo "[INFO]  Resource already exists, continuing..."
    else
      echo -e "[ERROR] ${CROSS} Got 400 bad request"
      exit 1
    fi
  elif [[ $status == "409" ]]; then
    OUTPUT="${body}"
    echo "[INFO]  Resource already exists, continuing..."
  else
    echo -e "[ERROR] ${CROSS} Request failed: ${body}..."
    exit 1
  fi
}


response=`curl -X POST https://$PLATFORM_API_EP/api/token \
               -s -k -H "Content-Type: application/json" -H "Accept: application/json" \
               -d "{ \"realm\": \"${realm}\",
                     \"username\": \"${username}\",
                     \"password\": \"${password}\",
                     \"client_id\": \"${client_id}\",
                     \"client_secret\": \"${client_secret}\",
                     \"grant_type\": \"password\" }"`
if [[ "$(echo ${response} | jq -r '.status')" == "401" ]]; then
    echo "[ERROR] Failed to authenticate"
    exit 1
else
    TOKEN=`echo ${response} | jq -r '.access_token'`
fi


echo "[INFO] Listing all products..."
RES=$(curl -kLsS https://$PLATFORM_API_EP/api/catalogs/$ORG/$CATALOG/products \
  -H "accept: application/json" \
  -H "authorization: Bearer ${TOKEN}")
handle_res "${RES}"
echo "$OUTPUT" | jq .
echo -e "\n\n\n"

echo "[INFO] Listing all apis..."
RES=$(curl -kLsS https://$PLATFORM_API_EP/api/catalogs/$ORG/$CATALOG/apis \
  -H "accept: application/json" \
  -H "authorization: Bearer ${TOKEN}")
handle_res "${RES}"
echo "$OUTPUT" | jq .


