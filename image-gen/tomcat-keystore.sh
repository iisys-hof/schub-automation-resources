#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
CERT_FILE=$1

KEY_FILE=$2

KEYSTORE_FILE=$3

EXPORT_PASS=superfluous

if [ -z "$CERT_FILE" ]; then
        echo "ERROR: No certificate file specified"
        return
fi

if [ -z "$KEY_FILE" ]; then
        echo "ERROR: No SSL key file specified"
        return
fi

if [ -z "$KEYSTORE_FILE" ]; then
        echo "ERROR: No keystore file specified"
        return
fi

# export key and certificate as pkcs12
echo "Exporting key and certificate to $TMP_DIRECTORY/$CERT_FILE/tmp.p12"
mkdir -p $TMP_DIRECTORY/$CERT_FILE/
openssl pkcs12 -export -in $CERT_FILE -inkey $KEY_FILE -out $TMP_DIRECTORY/$CERT_FILE/tmp.p12 -name tomcat -CAfile $CA_CERT -caname schub-root -passout pass:$EXPORT_PASS

# import into keystore under the name "tomcat"
echo "Importing pkcs12 file into keystore $KEYSTORE_FILE"
keytool -importkeystore -trustcacerts -noprompt -deststorepass changeit -destkeypass changeit -destkeystore $KEYSTORE_FILE -srckeystore $TMP_DIRECTORY/$CERT_FILE/tmp.p12 -srcstoretype PKCS12 -srcstorepass $EXPORT_PASS -alias tomcat

# remove temporary file
echo "Removing temporary pkcs12 file"
rm -r $TMP_DIRECTORY/$CERT_FILE/