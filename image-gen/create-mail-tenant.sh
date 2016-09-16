#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
TENANT_NAME=$1

TENANT_MAIL_DOMAIN=$2

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

if [ -z "$TENANT_MAIL_DOMAIN" ]; then
        echo "ERROR: No tenant mail domain specified"
        return
fi

## constants
REMOTE_TENANT_CREATE_SCRIPT=/home/ubuntu/mail-scripts/neworg.sh

# execute tenant creation script on remote host
echo "creating LDAP tenant $TENANT_NAME"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $MAIL_SSH_KEY $MAIL_SSH_USER@$MAIL_HOST $REMOTE_TENANT_CREATE_SCRIPT $TENANT_NAME $TENANT_MAIL_DOMAIN