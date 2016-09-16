#!/bin/bash

# setup
echo "reading global mail configuration"
source /home/ubuntu/mail-scripts/mail-config.sh

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
DOVECOT_CREATE_SCRIPT="$SCRIPTS_DIR/dovecot/neworg.sh"
POSTFIX_CREATE_SCRIPT="$SCRIPTS_DIR/postfix/neworg.sh"

# dovecot
$DOVECOT_CREATE_SCRIPT $TENANT_NAME

# postfix
$POSTFIX_CREATE_SCRIPT $TENANT_NAME $TENANT_MAIL_DOMAIN