#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Script directory: $SCRIPT_DIR"

echo "Running environment variables"
. $SCRIPT_DIR/env.sh

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

# TODO: Load in data automatically

# Pull secrets manager configuration to create template
SECRET_ARN=$(aws cloudformation describe-stacks \
    --stack-name MySqlRdsStack \
    --query 'Stacks[0].Outputs[?OutputKey==`SecretArn`].OutputValue' \
    --region $AWS_REGION \
    --output text)
SECRET=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --query SecretString --output text)
SM_USERNAME=$(echo $SECRET | jq -r '.username')
SM_PASSWORD=$(echo $SECRET | jq -r '.password')

# RDS Endpoint
RDS_ENDPOINT=$(aws cloudformation describe-stacks \
    --stack-name MySqlRdsStack \
    --query 'Stacks[0].Outputs[?OutputKey==`RdsEndpoint`].OutputValue' \
    --region $AWS_REGION \
    --output text)

# Create actual file from template
cp -i $SCRIPT_DIR/../load.sql.template $SCRIPT_DIR/../load.sql
sed -i "s,%HOSTNAME%,$HOSTNAME,g" $SCRIPT_DIR/../load.sql
sed -i "s/%PASSWORD%/$SM_PASSWORD/g" $SCRIPT_DIR/../load.sql
sed -i "s/%USERNAME%/$SM_USERNAME/g" $SCRIPT_DIR/../load.sql