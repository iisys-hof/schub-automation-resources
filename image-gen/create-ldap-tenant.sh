#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
TENANT_NAME=$1

TENANT_LDAP_PASS=$2

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

if [ -z "$TENANT_LDAP_PASS" ]; then
        echo "ERROR: No tenant LDAP admin password specified"
        return
fi

## constants
REMOTE_TENANT_CREATE_SCRIPT=/home/ubuntu/ldap/neworg.sh

# execute tenant creation script on remote host
echo "creating LDAP tenant $TENANT_NAME"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $LDAP_SSH_KEY $LDAP_SSH_USER@$LDAP_HOST $REMOTE_TENANT_CREATE_SCRIPT $TENANT_NAME $TENANT_LDAP_PASS
