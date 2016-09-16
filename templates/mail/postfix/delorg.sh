#!/bin/bash

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

## constants
TENANT_DIR="/etc/postfix/tenants"

POSTFIX_CONF_TEMPLATE="$SCRIPTS_DIR/postfix/main_template.cf"
POSTFIX_CONF_TMP="$SCRIPTS_DIR/postfix/main.cf"
POSTFIX_CONF="/etc/postfix/main.cf"

# remove individual file
sudo rm /etc/postfix/tenants/$TENANT_NAME.cf

# re-generate lists
echo "Generating ldap configuration list"

TENANT_FILE_LIST=""

for filename in $TENANT_DIR/*; do
    echo "adding file: $filename"
    TENANT_FILE_LIST="$TENANT_FILE_LIST, ldap:$filename"
done
# remove leading comma
TENANT_FILE_LIST=${TENANT_FILE_LIST:1}

# replace in postfix configuration
cat $POSTFIX_CONF_TEMPLATE | sed \
        -e "s!INSERT_TENANT_CONFIGS_HERE!$TENANT_FILE_LIST!" \
        > $POSTFIX_CONF_TMP
sudo cp $POSTFIX_CONF_TMP $POSTFIX_CONF
sudo rm $POSTFIX_CONF_TMP

# restart
sudo service postfix restart