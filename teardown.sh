#!/bin/bash

set -x

aws iam delete-role-policy --role-name convox-formation --policy-name all
aws iam delete-role --role-name convox-formation
aws lambda delete-function --function-name convox-formation

aws cloudformation delete-stack --stack-name s

while $(aws cloudformation describe-stacks --stack-name s &> /dev/null); do
  sleep 5
done

aws cloudformation delete-stack --stack-name staging

while $(aws cloudformation describe-stacks --stack-name staging &> /dev/null); do
  sleep 5
done
