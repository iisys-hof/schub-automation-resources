#!/bin/bash

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

## constants
TENANT_DIR="/etc/dovecot/tenants"

TENANT_CONF_LIST_TEMPLATE="$SCRIPTS_DIR/dovecot/tenant-db.ext"
TENANT_CONF_LIST_TMP="$SCRIPTS_DIR/dovecot/auth-ldap.conf.ext"
TENANT_CONF_LIST="/etc/dovecot/conf.d/auth-ldap.conf.ext"

# remove individual file
sudo rm /etc/dovecot/tenants/$TENANT_NAME.ext

# re-generate list
echo "Generating ldap configuration database list"
echo "" > $TENANT_CONF_LIST_TMP

for filename in $TENANT_DIR/*; do
    echo "adding file: $filename"
    cat $TENANT_CONF_LIST_TEMPLATE | sed \
        -e "s!INSERT_FILE_NAME_HERE!$filename!" \
        >> $TENANT_CONF_LIST_TMP
done
sudo cp $TENANT_CONF_LIST_TMP $TENANT_CONF_LIST
rm $TENANT_CONF_LIST_TMP

# restart
sudo service dovecot restart