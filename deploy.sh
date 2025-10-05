#!/bin/bash

S3_PREFIX="static-site-$(date +%s)"
STACK_NAME="StaticWebsite-Infra"
TEMPLATE_FILE="static-website-infra.yaml"
CONTENT_FOLDER_PATH="./demo-site"
PROFILE="personal"
REGIONS=("us-east-1" "us-east-2")
PRIMARY_REGION="us-east-1"

echo "Deploying CloudFormation stacks..."
for REGION in "${REGIONS[@]}"; do
    REGION_CODE=$(echo $REGION | sed 's/us-east-//')
    BUCKET_NAME="${S3_PREFIX}-${REGION_CODE}"
    STACK_FULL_NAME="${STACK_NAME}-${REGION_CODE}"

    echo "Deploying stack ${STACK_FULL_NAME} in ${REGION}..."

    aws cloudformation deploy \
        --stack-name "${STACK_FULL_NAME}" \
        --template-file "${TEMPLATE_FILE}" \
        --parameter-overrides UniqueBucketName="${BUCKET_NAME}" \
        --region "${REGION}" \
        --capabilities CAPABILITY_NAMED_IAM \
        --profile "${PROFILE}"

    if [ "${REGION}" == "${PRIMARY_REGION}" ]; then
        PRIMARY_BUCKET="${BUCKET_NAME}"
    fi
done

echo "Uploading content to S3..."
aws s3 sync "${CONTENT_FOLDER_PATH}" "s3://${PRIMARY_BUCKET}" \
    --region "${PRIMARY_REGION}" \
    --profile "${PROFILE}"

echo "Content uploaded to s3://${PRIMARY_BUCKET}"

echo "Retrieving CloudFront URL..."
CF_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}-1" \
    --region "${PRIMARY_REGION}" \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontUrl'].OutputValue" \
    --output text \
    --profile "${PROFILE}")

echo "Website URL: https://${CF_URL}"
