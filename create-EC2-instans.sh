#!/bin/bash

NAMES=$@
INSTANCE_TYPE="t2.micro"
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0be3218478ca5a153
DOMAIN_NAME=katuri395.online


# if mysql or mongodb instance_type should be t3.medium , for all others it is t2.micro

for i in $@
do  

    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z05425702D9GB0DBJQS32 --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done

# imporvement
# check instance is already created or not
# update route53 record