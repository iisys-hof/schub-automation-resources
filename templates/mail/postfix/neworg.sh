#!/bin/bash

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
TENANT_CONF_TEMPLATE="$SCRIPTS_DIR/postfix/ldap_tenant_users.cf"
TENANT_CONF_TMP="$SCRIPTS_DIR/postfix/$TENANT_NAME.cf"
TENANT_DIR="/etc/postfix/tenants"

POSTFIX_CONF_TEMPLATE="$SCRIPTS_DIR/postfix/main_template.cf"
POSTFIX_CONF_TMP="$SCRIPTS_DIR/postfix/main.cf"
POSTFIX_CONF="/etc/postfix/main.cf"

# generate individual file
echo "Generating tenant LDAP postfix configuration"
cat $TENANT_CONF_TEMPLATE | sed \
        -e "s/INSERT_LDAP_SERVER_HERE/$LDAP_SERVER/" \
        -e "s/INSERT_TENANT_NAME_HERE/$TENANT_NAME/" \
        -e "s/INSERT_LDAP_ADMIN_HERE/$LDAP_ADMIN/" \
        -e "s/INSERT_LDAP_ADMIN_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s/INSERT_MAIL_DOMAIN_HERE/$TENANT_MAIL_DOMAIN/" \
        > $TENANT_CONF_TMP
sudo cp $TENANT_CONF_TMP $TENANT_DIR/$TENANT_NAME.cf
rm $TENANT_CONF_TMP


# re-generate lists
# generate list of tenant conf files
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