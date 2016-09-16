#!/bin/bash

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

# constants
WORK_DIR="/home/ubuntu/ldap"
TMP_DIR="$WORK_DIR/tmp"

TENANT_DIRECTORY="/var/lib/ldap/$TENANT_NAME/"

echo "Retrieving configuration entry number"
TENANT_CONFIG_DB=`sudo ldapsearch  -Y EXTERNAL -H ldapi:/// -b cn=config 'olcDatabase={1}hdb' | grep -B1 $TENANT_DIRECTORY | grep olcDatabase | awk '{print $2}'`

# delete tenant entries and directories
echo "Stopping OpenLDAP server"
sudo service slapd stop

echo "Removing LDAP configuration entry"
sudo rm /etc/ldap/slapd.d/cn\=config/olcDatabase=$TENANT_CONFIG_DB.ldif

echo "Deleting tenant LDAP data"
sudo rm -rf $TENANT_DIRECTORY

echo "Starting OpenLDAP server"
sudo service slapd start