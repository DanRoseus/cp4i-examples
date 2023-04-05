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

CROSS="\xE2\x9D\x8C"

PLATFORM_API_EP=$(oc get route -n $NAMESPACE ${RELEASE}-mgmt-platform-api -o jsonpath="{.spec.host}")
[[ -z $PLATFORM_API_EP ]] && echo -e "[ERROR] ${CROSS} APIC platform api route doesn't exit" && exit 1
$DEBUG && echo "[DEBUG] PLATFORM_API_EP=${PLATFORM_API_EP}"

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


echo "[INFO] Deleting all products..."
RES=$(curl -kLsS -X DELETE https://$PLATFORM_API_EP/api/catalogs/$ORG/$CATALOG/products?confirm=$CATALOG \
  -H "accept: application/json" \
  -H "authorization: Bearer ${TOKEN}")
echo "$RES" | jq .
echo -e "\n\n\n"
