#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

echo "Pulling environment variables configuration"
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION=`aws configure get region`

# Check for security group
echo "Checking for CDK Bootstrap in current $AWS_REGION..."
cfn=$(aws cloudformation describe-stacks \
    --query "Stacks[?StackName=='CDKToolkit'].StackName" \
    --region $AWS_REGION \
    --output text)
if [[ -z "$cfn" ]]; then
    cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION
fi

# Deploy CDK
echo "Launching CDK application..."
cd $SCRIPT_DIR/../cdk
cdk synth
cdk deploy --all --require-approval never

# CDK Outputs
echo "CloudFormation Outputs..."
RDS_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name MySQLStack \
    --query 'Stacks[0].Outputs[?OutputKey==`RdsEndpointExport`].OutputValue' \
    --region $AWS_REGION \
    --output text)
echo "RDS Endpoint: $RDS_ENDPOINT"

RDS_IDENTIFIER=$(aws cloudformation describe-stacks \
    --stack-name MySQLStack \
    --query 'Stacks[0].Outputs[?OutputKey==`RdsInstanceIdentifier`].OutputValue' \
    --region $AWS_REGION \
    --output text)
echo "RDS Identifier: $RDS_IDENTIFIER"

RDS_PG_NAME=$(aws cloudformation describe-stacks \
    --stack-name MySQLStack \
    --query 'Stacks[0].Outputs[?OutputKey==`RdsParameterGroupName`].OutputValue' \
    --region $AWS_REGION \
    --output text)
echo "RDS Parameter Group Name: $RDS_PG_NAME"

SG_ID=$(aws cloudformation describe-stacks \
    --stack-name MySQLStack \
    --query 'Stacks[0].Outputs[?OutputKey==`RdsSecurityGroup`].OutputValue' \
    --region $AWS_REGION \
    --output text)
echo "RDS Security Group Id: $SG_ID"