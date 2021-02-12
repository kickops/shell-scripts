#!/bin/bash

profile="<aws-profile-to-use>"
hosted_zone="<ZONEID>"
domain_name=$1
ns_value=$2

IFS=',' read -a ns_array <<< "$ns_value"

ns1=${ns_array[0]}
ns2=${ns_array[1]}
ns3=${ns_array[2]}
ns4=${ns_array[3]}

# Creates route 53 records based on env name

aws --profile $profile route53 change-resource-record-sets --hosted-zone-id $hosted_zone --change-batch '{ "Comment": "Create a NS record set for the domain in freshworkscorp.com hsoted zone", "Changes": [ { "Action": "CREATE","ResourceRecordSet": { "Name": "'"$domain_name"'", "Type": "NS", "TTL": 300, "ResourceRecords": [ { "Value": "'"$ns1"'" }, { "Value": "'"$ns2"'" }, { "Value": "'"$ns3"'" }, { "Value": "'"$ns4"'" } ] } } ] }'
