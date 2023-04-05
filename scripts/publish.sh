#!/bin/bash
#******************************************************************************
# Licensed Materials - Property of IBM
# (c) Copyright IBM Corporation 2020. All Rights Reserved.
#
# Note to U.S. Government Users Restricted Rights:
# Use, duplication or disclosure restricted by GSA ADP Schedule
# Contract with IBM Corp.
#******************************************************************************

DEBUG=true
TICK="\xE2\x9C\x85"
CROSS="\xE2\x9D\x8C"

NAMESPACE=dan
PRODUCT=swagger-test
RELEASE=ademo
INTEGRATION_RUNTIME=test-http-routes-noauth

function usage() {
  echo "Usage: $0 -n <namespace> -d"
}

while getopts "n:r:p:i:" opt; do
  case ${opt} in
  n)
    NAMESPACE="$OPTARG"
    ;;
  r)
    RELEASE="$OPTARG"
    ;;
  p)
    PRODUCT="$OPTARG"
    ;;
  i)
    INTEGRATION_RUNTIME="$OPTARG"
    ;;
  \?)
    usage
    exit
    ;;
  esac
done

OPENAPI_DOC_1=./swagger-${INTEGRATION_RUNTIME}-1.json
OPENAPI_DOC_2=./swagger-${INTEGRATION_RUNTIME}-2.json
PRODUCT_DOC=./product.yaml

client_id="599b7aef-8841-4ee2-88a0-84d49c4d6ff2"
client_secret="0ea28423-e73b-47d4-b40e-ddb45c48bb0c"
realm=provider/default-idp-2
username=cp4i-admin
password=engageibmAPI1
ORG=main-demo
CATALOG=main-demo-catalog
C_ORG=${ORG}-corp
APP=${PRODUCT}-app
APP_TITLE=${APP}

CORG_OWNER_USERNAME="${ORG}-corg-admin"
CORG_OWNER_PASSWORD=engageibmAPI1

PLATFORM_API_EP=$(oc get route -n $NAMESPACE ${RELEASE}-mgmt-platform-api -o jsonpath="{.spec.host}")
[[ -z $PLATFORM_API_EP ]] && echo -e "[ERROR] ${CROSS} APIC platform api route doesn't exit" && exit 1
$DEBUG && echo "[DEBUG] PLATFORM_API_EP=${PLATFORM_API_EP}"

JQ=jq

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

echo "[INFO] Publishing..."
RES=$(curl -kLsS -X POST https://$PLATFORM_API_EP/api/catalogs/$ORG/$CATALOG/publish \
-H "accept: application/json" \
-H "authorization: Bearer ${TOKEN}" \
-H "content-type: multipart/form-data" \
-F "openapi=@${OPENAPI_DOC_1};type=application/yaml" \
-F "openapi=@${OPENAPI_DOC_2};type=application/yaml" \
-F "product=@${PRODUCT_DOC};type=application/yaml")
handle_res "${RES}"
echo $OUTPUT | jq .
