#!/bin/bash
tag_name=$1
tag_value=$2
# if user doesnot pass tag_name as 1 argument assign Env as default
if [[ -z $tag_name ]]; then
    tag_name="Env"
fi
# if user doesnot pass tag_value as 2 argument assign QA as default
if [[ -z $tag_value ]]; then
    tag_value="Dev"
fi

instanceIds=$(aws ec2 describe-instances --filters "Name=tag:Env,Values=Dev" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)

if [[ -n $instanceIds ]]; then
    echo "The instance ids which will be shutdown are ${instanceIds}"
    aws ec2 stop-instances --instance-ids ${instanceIds}
else
    echo "No instances found with matching criteria Env = Dev"
fi
