#!/bin/bash

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

## constants
TENANT_CONF_TEMPLATE="$SCRIPTS_DIR/dovecot/tenant-ldap.ext"
TENANT_CONF_TMP="$SCRIPTS_DIR/dovecot/$TENANT_NAME.ext"
TENANT_DIR="/etc/dovecot/tenants"

TENANT_CONF_LIST_TEMPLATE="$SCRIPTS_DIR/dovecot/tenant-db.ext"
TENANT_CONF_LIST_TMP="$SCRIPTS_DIR/dovecot/auth-ldap.conf.ext"
TENANT_CONF_LIST="/etc/dovecot/conf.d/auth-ldap.conf.ext"

# generate individual file
echo "Generating tenant LDAP dovecot configuration"
cat $TENANT_CONF_TEMPLATE | sed \
        -e "s/INSERT_LDAP_SERVER_HERE/$LDAP_SERVER/" \
        -e "s/INSERT_LDAP_ADMIN_HERE/$LDAP_ADMIN/" \
        -e "s/INSERT_LDAP_ADMIN_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s/INSERT_TENANT_NAME_HERE/$TENANT_NAME/" \
        > $TENANT_CONF_TMP
sudo cp $TENANT_CONF_TMP $TENANT_DIR/$TENANT_NAME.ext
rm $TENANT_CONF_TMP

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