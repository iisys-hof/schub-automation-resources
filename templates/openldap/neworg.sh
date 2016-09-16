#!/bin/bash

## input values
TENANT_NAME=$1

SUB_ADMIN_PASS=$2

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

if [ -z "$SUB_ADMIN_PASS" ]; then
        echo "ERROR: No tenant admin password specified"
        return
fi

# constants
WORK_DIR="/home/ubuntu/ldap"
TMP_DIR="$WORK_DIR/tmp"

LDAP_ADMIN_USER="cn=admin,dc=schub,dc=de"

NEW_ADMIN="cn=admin,dc=$TENANT_NAME,dc=org"

TENANT_DIRECTORY="/var/lib/ldap/$TENANT_NAME/"

NEWORG_TEMPLATE="$WORK_DIR/neworg.ldif"
NEWORG_TMP="$TMP_DIR/neworg.ldif"

NEWTREE_TEMPLATE="$WORK_DIR/neworg-tree.ldif"
NEWTREE_TMP="$TMP_DIR/neworg-tree.ldif"

NEWACL_TEMPLATE="$WORK_DIR/neworg-acl.ldif"
NEWACL_TMP="$TMP_DIR/neworg-acl.ldif"

# create tenant directories and LDAP tree
echo "Creating tenant LDAP directories"
sudo mkdir $TENANT_DIRECTORY
sudo chown -R openldap $TENANT_DIRECTORY
sudo chgrp -R openldap $TENANT_DIRECTORY

# create ldifs from templates
cat $NEWORG_TEMPLATE | sed \
    -e "s/INSERT_TENANT_NAME_HERE/$TENANT_NAME/" \
    -e "s/INSERT_SUB_ADMIN_PASS_HERE/$SUB_ADMIN_PASS/" \
    > $NEWORG_TMP

cat $NEWTREE_TEMPLATE | sed \
    -e "s/INSERT_TENANT_NAME_HERE/$TENANT_NAME/" \
    > $NEWTREE_TMP

echo "Creating new LDAP dit"
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f $NEWORG_TMP

echo "Creating tenant tree and admin '$NEW_ADMIN'"
sudo ldapadd -H ldap://127.0.0.1 -x -D "$NEW_ADMIN" -f $NEWTREE_TMP -w $SUB_ADMIN_PASS

echo "Retrieving configuration entry number"
TENANT_CONFIG_DB=`sudo ldapsearch  -Y EXTERNAL -H ldapi:/// -b cn=config 'olcDatabase={1}hdb' | grep -B1 $TENANT_DIRECTORY | grep olcDatabase | awk '{print $2}'`

echo "Setting access control lists"
cat $NEWACL_TEMPLATE | sed \
    -e "s/INSERT_TENANT_CONFIG_DB_HERE/$TENANT_CONFIG_DB/g" \
    -e "s/INSERT_TENANT_NAME_HERE/$TENANT_NAME/g" \
    -e "s/INSERT_LDAP_ADMIN_USER_HERE/$LDAP_ADMIN_USER/g" \
    > $NEWACL_TMP

sudo ldapmodify  -Y EXTERNAL -H ldapi:/// -f $NEWACL_TMP

# remove temporary files
echo "Cleaning Up"
rm -r $TMP_DIR/*