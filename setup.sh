#!/bin/bash

set -x

# Create Lambda Role and Function

role=$(aws iam create-role --role-name convox-formation --assume-role-policy-document file://role-assume.json | jq -r .Role.Arn)
aws iam put-role-policy --role-name convox-formation --policy-name all --policy-document file://role-policy.json

sleep 5

zip lambda.zip index.js

aws lambda create-function \
  --function-name convox-formation \
  --runtime nodejs \
  --role $role \
  --handler index.handler \
  --zip-file fileb://lambda.zip

# Create Cluster

git clone --depth 1 https://github.com/convox/kernel

aws cloudformation create-stack \
  --capabilities CAPABILITY_IAM \
  --parameters ParameterKey=Ami,ParameterValue=ami-6b88b95b \
  --stack-name staging \
  --template-body=file://kernel/data/cluster.json

STATUS="CREATE_IN_PROGRESS"
while [[ "$STATUS" == *_PROGRESS ]]; do
  STATUS=$(aws cloudformation describe-stacks --stack-name staging | jq -r .Stacks[].StackStatus)
  sleep 5
done

[[ "$STATUS" != "CREATE_COMPLETE" ]] && exit 1

SUBNETS=$(aws cloudformation describe-stacks --stack-name staging | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="Subnets") | .OutputValue' | sed "s/,/\\\,/g")
VPC=$(aws cloudformation describe-stacks --stack-name staging | jq -r '.Stacks[].Outputs[] | select(.OutputKey=="Vpc") | .OutputValue')

# Create App Release Stack

docker pull convox/app

cat <<EOF | docker run -i convox/app -mode staging > app.tmpl
web:
  image: httpd
  ports:
    - 3000:80
EOF

aws cloudformation create-stack \
  --capabilities CAPABILITY_IAM \
  --parameters ParameterKey=Cluster,ParameterValue=staging ParameterKey=Kernel,ParameterValue=arn:aws:lambda:us-west-2:901416387788:function:convox-formation ParameterKey=Subnets,ParameterValue=\'$SUBNETS\' ParameterKey=VPC,ParameterValue=$VPC ParameterKey=WebImage,ParameterValue=httpd \
  --stack-name s \
  --template-body=file://app.tmpl

STATUS="CREATE_IN_PROGRESS"
while [[ "$STATUS" == *_PROGRESS ]]; do
  STATUS=$(aws cloudformation describe-stacks --stack-name s | jq -r .Stacks[].StackStatus)
  sleep 5
done

