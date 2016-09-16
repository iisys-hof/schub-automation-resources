#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

## constants
REMOTE_TENANT_DELETE_SCRIPT=/home/ubuntu/mail-scripts/delorg.sh

# execute tenant deletion script on remote host
echo "deleting mail tenant $TENANT_NAME"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $MAIL_SSH_KEY $MAIL_SSH_USER@$MAIL_HOST $REMOTE_TENANT_DELETE_SCRIPT $TENANT_NAME
