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
REMOTE_TENANT_DELETE_SCRIPT=/home/ubuntu/ldap/delorg.sh

# execute tenant deletion script on remote host
echo "deleting LDAP tenant $TENANT_NAME"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $LDAP_SSH_KEY $LDAP_SSH_USER@$LDAP_HOST $REMOTE_TENANT_DELETE_SCRIPT $TENANT_NAME
