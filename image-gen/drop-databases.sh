#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
TENANT_NAME=$1

if [ -z "$TENANT_NAME" ]; then
        echo "ERROR: No tenant name specified"
        return
fi

## constants
DROP_CAMUNDA=true
DROP_LIFERAY=true
DROP_NUXEO=true
DROP_OX=true

CAMUNDA_DB_NAME=camunda_$TENANT_NAME

LIFERAY_DB_NAME=liferay_$TENANT_NAME

NUXEO_DB_NAME=nuxeo_$TENANT_NAME

OX_CONF_DB_NAME=open_xchange_$TENANT_NAME
OX_DATA_DB_NAME=open_xchange_data_$TENANT_NAME
SUFFIX=_5
OX_DATA_DB_NAME_AUX=open_xchange_data_$TENANT_NAME$SUFFIX


## database creation
# camunda
if [[ "$DROP_CAMUNDA" == "true" ]]; then
    echo "Dropping Camunda database"
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS -e "drop database $CAMUNDA_DB_NAME;"
fi

# liferay
if [[ "$DROP_LIFERAY" == "true" ]]; then
    echo "Dropping Liferay database"
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS -e "drop database $LIFERAY_DB_NAME;"
fi

# nuxeo
if [[ "$DROP_NUXEO" == "true" ]]; then
    echo "Dropping Nuxeo database"
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS -e "drop database $NUXEO_DB_NAME;"
fi

# open-xchange
if [[ "$DROP_OX" == "true" ]]; then
    echo "Dropping Open-Xchange databases"
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS -e "drop database $OX_CONF_DB_NAME;"
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS -e "drop database $OX_DATA_DB_NAME;"
    mysql -u $MARIADB_USER -h $MARIADB_HOST -P $MARIADB_PORT -p$MARIADB_PASS -e "drop database $OX_DATA_DB_NAME_AUX;"
fi

