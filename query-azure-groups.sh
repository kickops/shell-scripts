#!/bin/bash
#Author: Kicky
#Purpose: Queries the azure AD and gives back a command to be executed in the Auth machine

out="/usr/bin/teleport-setup-auth "
map_key="$1"

2>/dev/null
i_obj=`az ad group show -g aws-${map_key}-infra 2>/dev/null` 
ao_obj=`az ad group show -g aws-${map_key}-app-ops 2>/dev/null`
ad_obj=`az ad group show -g aws-${map_key}-app-dev 2>/dev/null`
i_id=`echo $i_obj | jq .objectId` 
ao_id=`echo $ao_obj | jq .objectId`
ad_id=`echo $ad_obj | jq .objectId`

if [ -n "${i_id}" ]; then 
  out="$out -i $i_id"
fi
if [ -n "${ao_id}" ]; then 
  out="$out -ao $ao_id"
fi
if [ -n "${ad_id}" ]; then 
  out="$out -ad $ad_id"
fi

out="$out -x /etc/teleport.d/saml-metadata.xml"
echo $out
