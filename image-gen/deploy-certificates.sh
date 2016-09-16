#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
TENANT_NAME=$1

TENANT_SERVER=$2

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

if [ -z "$TENANT_SERVER" ]; then
        echo "ERROR: No tenant server specified"
        return
fi

## constants
CERT_FOLDER=certs/$TENANT_NAME-cert
TARGET_FOLDER=/home/ubuntu/cert-services/

# create target folder and copy certificates
echo "Creating $TENANT_SERVER:$TARGET_FOLDER"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $SSH_MAINTENANCE_KEY $SSH_MAINTENANCE_USER@$TENANT_SERVER mkdir $TARGET_FOLDER

echo "Copying certificates to $TENANT_SERVER"
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -B -i $SSH_MAINTENANCE_KEY $CERT_FOLDER/* $SSH_MAINTENANCE_USER@$TENANT_SERVER:$TARGET_FOLDER
