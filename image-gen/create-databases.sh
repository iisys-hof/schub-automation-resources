#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
TENANT_NAME=$1

CAMUNDA_PASSWORD=$2

LIFERAY_PASSWORD=$3

NUXEO_PASSWORD=$4

OX_PASSWORD=$5

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

if [ -z "$CAMUNDA_PASSWORD" ]; then
        echo "ERROR: No Camunda database password specified"
        return
fi

if [ -z "$LIFERAY_PASSWORD" ]; then
        echo "ERROR: No Liferay database password specified"
        return
fi

if [ -z "$NUXEO_PASSWORD" ]; then
        echo "ERROR: No Nuxeo database password specified"
        return
fi

if [ -z "$OX_PASSWORD" ]; then
        echo "ERROR: No Open-Xchange database password specified"
        return
fi

## constants
CREATE_CAMUNDA=true
CREATE_LIFERAY=true
CREATE_NUXEO=true
CREATE_OX=true

CAMUNDA_SQL_TEMPLATE=$TEMPLATE_REPO_DIRECTORY/mariadb/camunda.sql
CAMUNDA_SQL_TMP=$TMP_DIRECTORY/camunda.sql
CAMUNDA_INIT_SQL=$TEMPLATE_REPO_DIRECTORY/mariadb/camunda-mysql-create.sql

CAMUNDA_DB_NAME=camunda_$TENANT_NAME
CAMUNDA_DB_USER=camunda_$TENANT_NAME

LIFERAY_SQL_TEMPLATE=$TEMPLATE_REPO_DIRECTORY/mariadb/liferay.sql
LIFERAY_SQL_TMP=$TMP_DIRECTORY/liferay.sql

LIFERAY_DB_NAME=liferay_$TENANT_NAME
LIFERAY_DB_USER=liferay_$TENANT_NAME

NUXEO_SQL_TEMPLATE=$TEMPLATE_REPO_DIRECTORY/mariadb/nuxeo.sql
NUXEO_SQL_TMP=$TMP_DIRECTORY/nuxeo.sql

NUXEO_DB_NAME=nuxeo_$TENANT_NAME
NUXEO_DB_USER=nuxeo_$TENANT_NAME

OX_SQL_TEMPLATE=$TEMPLATE_REPO_DIRECTORY/mariadb/open-xchange.sql
OX_SQL_TMP=$TMP_DIRECTORY/open-xchange.sql

OX_CONF_DB_NAME=open_xchange_$TENANT_NAME
OX_DATA_DB_NAME=open_xchange_data_$TENANT_NAME
OX_DB_USER=open_xchange_$TENANT_NAME

# TODO: check if databases exist first?

## database creation
# camunda
if [[ "$CREATE_CAMUNDA" == "true" ]]; then
    echo "Creating Camunda database ($CAMUNDA_DB_NAME) and user ($CAMUNDA_DB_USER)"
    cat $CAMUNDA_SQL_TEMPLATE | sed \
            -e "s/INSERT_DB_NAME_HERE/$CAMUNDA_DB_NAME/" \
            -e "s/INSERT_DB_USER_HERE/$CAMUNDA_DB_USER/" \
            -e "s/INSERT_DB_PASSWORD_HERE/$CAMUNDA_PASSWORD/" \
            > $CAMUNDA_SQL_TMP
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS < $CAMUNDA_SQL_TMP

    echo "Initializing Camunda database"
    # TODO: move database initialization and upgrades into container? would require an SQL-Client
    # TODO: execute as camunda user?
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS $CAMUNDA_DB_NAME < $CAMUNDA_INIT_SQL
fi

# liferay
if [[ "$CREATE_LIFERAY" == "true" ]]; then
    echo "Creating Liferay database ($LIFERAY_DB_NAME) and user ($LIFERAY_DB_USER)"
    cat $LIFERAY_SQL_TEMPLATE | sed \
            -e "s/INSERT_DB_NAME_HERE/$LIFERAY_DB_NAME/" \
            -e "s/INSERT_DB_USER_HERE/$LIFERAY_DB_USER/" \
            -e "s/INSERT_DB_PASSWORD_HERE/$LIFERAY_PASSWORD/" \
            > $LIFERAY_SQL_TMP
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS < $LIFERAY_SQL_TMP
fi

# nuxeo
if [[ "$CREATE_NUXEO" == "true" ]]; then
    echo "Creating Nuxeo database ($NUXEO_DB_NAME) and user ($NUXEO_DB_USER)"
    cat $NUXEO_SQL_TEMPLATE | sed \
            -e "s/INSERT_DB_NAME_HERE/$NUXEO_DB_NAME/" \
            -e "s/INSERT_DB_USER_HERE/$NUXEO_DB_USER/" \
            -e "s/INSERT_DB_PASSWORD_HERE/$NUXEO_PASSWORD/" \
            > $NUXEO_SQL_TMP
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS < $NUXEO_SQL_TMP
fi

# open-xchange
if [[ "$CREATE_OX" == "true" ]]; then
echo "Creating Open-Xchange databases ($OX_CONF_DB_NAME, $OX_DATA_DB_NAME) and user ($OX_DB_USER)"
    cat $OX_SQL_TEMPLATE | sed \
            -e "s/INSERT_CONF_DB_NAME_HERE/$OX_CONF_DB_NAME/" \
            -e "s/INSERT_DATA_DB_NAME_HERE/$OX_DATA_DB_NAME/" \
            -e "s/INSERT_DB_USER_HERE/$OX_DB_USER/" \
            -e "s/INSERT_DB_PASSWORD_HERE/$OX_PASSWORD/" \
            > $OX_SQL_TMP
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS < $OX_SQL_TMP
fi

## remove temporary files
echo "Removing temporary files"
rm $CAMUNDA_SQL_TMP
rm $LIFERAY_SQL_TMP
rm $NUXEO_SQL_TMP
rm $OX_SQL_TMP
