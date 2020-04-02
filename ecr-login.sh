#!/bin/bash
# RUN me where kubectl is available,& make sure to replace account,region etc
#
ACCOUNT=504263020452
REGION=us-east-1
SECRET_NAME=${REGION}-ecr-registry
EMAIL=babu.gmk777@gmail.com

#
# Fetch token (which will expire in 12 hours)
#

TOKEN=`aws ecr --region=$REGION get-authorization-token --output text --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2`

#
# Create or replace registry secret
#

kubectl delete secret --ignore-not-found $SECRET_NAME
kubectl create secret docker-registry $SECRET_NAME \
 --docker-server=https://${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com \
 --docker-username=AWS \
 --docker-password="${TOKEN}" \
 --docker-email="${EMAIL}"