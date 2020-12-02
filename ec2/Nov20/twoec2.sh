#!/bin/bash

current_region="ap-south-1"
ubuntu_20_amiid="ami-0a4a70bd98c6d6441"
windows_2019_amid="ami-0994975f92b8520bc"

echo "fetching the aws default vpc id"
# find default vpc id in your region
vpc_id=$(aws ec2 describe-vpcs --query "Vpcs[?IsDefault].VpcId" --output text)
echo "created the vpc with id ${vpc_id}"


# Create a security group
sgroupname='openforgol'
echo "Creating the security group with name ${sgroupname}"

aws ec2 create-security-group --description "open 22 80 and 8080 port" --group-name ${sgroupname} --vpc-id $vpc_id

# store security group id into some variable
sg_id=$(aws ec2 describe-security-groups --group-names ${sgroupname} --query "SecurityGroups[0].GroupId" --output text)
echo "Created security group with id ${sg_id}"
# openports
for port_number in 22 80 8080
do
    echo "Creating a security group ingress rule for ${port_number}"
    aws ec2 authorize-security-group-ingress --group-name ${sgroupname} --protocol tcp --port "$port_number" --cidr 0.0.0.0/0
done

key_name="my-key"
# if you dont have a key use ssh-keygen
echo "importing key pair"
aws ec2 import-key-pair --key-name $key_name --public-key-material fileb://~/.ssh/id_rsa.pub

az_a="${current_region}a"
az_b="${current_region}b"


#subnet id in az -a
subnet_a=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=${az_a}" "Name=vpc-id,Values=$vpc_id" --query "Subnets[0].SubnetId" --output text)
echo "subnet in ${az_a} is ${subnet_a}"
#subnet id in az-b
subnet_b=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=${az_b}" "Name=vpc-id,Values=$vpc_id" --query "Subnets[0].SubnetId" --output text)
echo "subnet in ${az_b} is ${subnet_b}"

default_instance_type='t2.micro'

aws ec2 run-instances --image-id $ubuntu_20_amiid --instance-type $default_instance_type --key-name $key_name --security-group-ids $sg_id --subnet-id $subnet_a --count 1

aws ec2 run-instances --image-id $windows_2019_amid --instance-type $default_instance_type --key-name $key_name --security-group-ids $sg_id --subnet-id $subnet_b --count 1
