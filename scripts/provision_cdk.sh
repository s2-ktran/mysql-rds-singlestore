#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

echo "Pulling environment variables configuration"
export AWS_ACCOUNT_ID=`aws sts get-caller-identity --query Account --output text`
export AWS_REGION=`aws sts get-calleer-identity --query Region --output text`

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

# RDS Endpoint
RDS_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name MySqlRdsStack \
    --query 'Stacks[0].Outputs[?OutputKey==`RdsEndpoint`].OutputValue' \
    --region $AWS_REGION \
    --output text)