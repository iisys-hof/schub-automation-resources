#!/bin/bash

# setup
echo "reading global mail configuration"
source /home/ubuntu/mail-scripts/mail-config.sh

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

## constants
DOVECOT_DELETE_SCRIPT="$SCRIPTS_DIR/dovecot/delorg.sh"
POSTFIX_DELETE_SCRIPT="$SCRIPTS_DIR/postfix/delorg.sh"

# postfix
$POSTFIX_DELETE_SCRIPT $TENANT_NAME

# dovecot
$DOVECOT_DELETE_SCRIPT $TENANT_NAME