#!/bin/bash
STACK_NAME="CloudyCups-Website"
TEMPLATE_FILE="cloudycups-website-infra.yaml"
CONTENT_FOLDER="./demo-site"
PROFILE="personal"

BUCKET_NAME="cloudycups-$(date +%s)"
DOMAIN="cloudycups.in"
SUBDOMAIN="www"
HOSTED_ZONE_ID="Z09492383KUBJWU0UQ2C0"
CLOUDFRONT_HOSTED_ZONE_ID="Z2FDTNDATAQYW2"
AWS_REGION="us-east-1"


echo "Deploying CloudFormation stack..."
aws cloudformation deploy \
    --stack-name "${STACK_NAME}" \
    --template-file "${TEMPLATE_FILE}" \
    --parameter-overrides \
        UniqueBucketName="${BUCKET_NAME}" \
        DomainName="${DOMAIN}" \
        SubDomain="${SUBDOMAIN}" \
        HostedZoneId="${HOSTED_ZONE_ID}" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region "${AWS_REGION}" \
    --profile "${PROFILE}"


echo "Uploading website content to S3..."
aws s3 sync "${CONTENT_FOLDER}" "s3://${BUCKET_NAME}" \
    --region "${AWS_REGION}" \
    --profile "${PROFILE}"


echo "Deployment complete."
echo "Website URL: https://${SUBDOMAIN}.${DOMAIN}"



