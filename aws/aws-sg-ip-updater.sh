#!/bin/bash

###############################################
# IP SG Updater by Lechu                      #
#                                             #
# Complete the information about the IAM USER #
# Credentials in AWS_* Variables              #
#                                             #
# The IAM USER should be able to change       #
# SG rules In the VPC                         #
###############################################


export AWS_PROFILE=default
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=xXXxxXXxXXXxxxxXXXXxxxXXXXxXXXxXXxXXXxXx
export AWS_DEFAULT_OUTPUT=json
export AWS_DEFAULT_REGION=sa-east-1

USER=$1
GRPID=sg-xxxxxxxx

if [[ -z $1 ]]
then
clear
printf "

ERROR: Command $0 must be executed specifying the user described in the Description field:

E:

$0 Lechu

NOTE: $0 is extracting the users pecifyed in the \"Description\" field, please wait a moment ...

"

aws ec2 describe-security-groups --group-ids $GRPID | grep Description
echo " "
exit
fi


OLDIP=`aws ec2 describe-security-groups --group-ids $GRPID | grep -A1 $USER | grep CidrIp | awk -F'"' '{print $4}' | awk -F"/" '{print $1}'`
MYIP=`curl -s eth0.me`


if [ $MYIP == $OLDIP ]
then
clear
printf "

SAME IP DETECTED, skipping ...

"
else
	clear

	printf "
	Applying Ingress ALL/ALL ANY/ANY for IP: $MYIP in the Security Group: $GRPID
	"

	aws ec2 revoke-security-group-ingress --group-id "$GRPID" --ip-permissions '[{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "'$OLDIP'/32"}]}]'

	aws ec2 authorize-security-group-ingress --group-id "$GRPID" --ip-permissions '[{"IpProtocol": "-1", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "'$MYIP'/32", "Description": "'$USER'"}]}]'

fi
