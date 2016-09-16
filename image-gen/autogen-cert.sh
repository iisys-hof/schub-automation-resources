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

TENANT_DOMAIN=$TENANT_NAME.schub.local

CA_CONFIG=ca/openssl.cnf

SSL_CONF=$TMP_DIRECTORY/openssl.cnf
SSL_CONF_TEMPLATE=$TEMPLATE_REPO_DIRECTORY/openssl/openssl.cnf

TARGET_FOLDER=certs/$TENANT_NAME-cert

# set subject alternate names
echo "Generating configuration template for *.$TENANT_DOMAIN"
cat $SSL_CONF_TEMPLATE | sed \
      -e "s/INSERT_SERVICE_DNS_HERE/*.$TENANT_DOMAIN/" \
      -e "s/INSERT_TENANT_DNS_HERE/$TENANT_DOMAIN/" \
      > $SSL_CONF

# generate request
echo "Generating Certificate Signing Request"
openssl req -nodes -newkey rsa:2048 -keyout $TMP_DIRECTORY/$TENANT_NAME.key -out $TMP_DIRECTORY/$TENANT_NAME.csr -subj "/C=DE/ST=Bayern/L=Hof/O=Social Collaboration Hub/OU=Systemintegration/CN=*.$TENANT_NAME.schub.local" -config $SSL_CONF

# sign request
echo "Singing Certificate Signing Request"
openssl ca -batch -in $TMP_DIRECTORY/$TENANT_NAME.csr -config $CA_CONFIG -out $TMP_DIRECTORY/$TENANT_NAME.crt -days 3650

# generate chain (only this will be supplied)
echo "Generating Certificate Chain"
cat $TMP_DIRECTORY/$TENANT_NAME.crt $INTERMEDIATE_CERT $CA_CERT > $TMP_DIRECTORY/$TENANT_NAME.chain.crt

# generate keystore
echo "Generating Tomcat Keystore"
./tomcat-keystore.sh $TMP_DIRECTORY/$TENANT_NAME.chain.crt $TMP_DIRECTORY/$TENANT_NAME.key $TMP_DIRECTORY/$TENANT_NAME.keystore

# deploy certificates and keystore
mkdir -p $TARGET_FOLDER
echo "Deploying generated SSL files to $TARGET_FOLDER"
mv $TMP_DIRECTORY/$TENANT_NAME.chain.crt $TARGET_FOLDER/$TENANT_NAME.crt
mv $TMP_DIRECTORY/$TENANT_NAME.key $TARGET_FOLDER/$TENANT_NAME.key
mv $TMP_DIRECTORY/$TENANT_NAME.keystore $TARGET_FOLDER/keystore

# delete temporary files
echo "Removing temporary files"
rm $SSL_CONF
rm $TMP_DIRECTORY/$TENANT_NAME.csr
rm $TMP_DIRECTORY/$TENANT_NAME.crt

echo "autogen-cert.sh finished"
