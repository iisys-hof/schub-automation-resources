#!/bin/bash

## constants
SERVICES_CONF="/etc/nginx/sites-enabled/default"
SERVICES_CONF_TEMPLATE="/templates/schub-services-site"
SERVICES_CONF_TMP="/tmp/schub-services-site"

## read environment variables
# check and set default values

if [ -z "$TENANT_NAME" ]; then
        TENANT_NAME=tenant
        echo "ERROR: No tenant name supplied, using default: $TENANT_NAME"
fi

if [ -z "$LOCAL_DOMAIN" ]; then
        LOCAL_DOMAIN=schub.local
        echo "ERROR: No local domain supplied, using default: $LOCAL_DOMAIN"
fi

if [ -z "$WEAVE_DNS" ]; then
        WEAVE_DNS=172.17.0.1
        echo "WARNING: No weave DNS server supplied, using default: $WEAVE_DNS"
fi

if [ -z "$MAX_REQUEST_SIZE" ]; then
        MAX_REQUEST_SIZE=512M
        echo "WARNING: No maximum request size supplied, using default: $MAX_REQUEST_SIZE"
fi

## replace variables in template
echo "Configuring reverse proxy"
cat $SERVICES_CONF_TEMPLATE | sed \
        -e "s!INSERT_TENANT_NAME_HERE!$TENANT_NAME!g" \
        -e "s!INSERT_LOCAL_DOMAIN_HERE!$LOCAL_DOMAIN!g" \
        -e "s!INSERT_WEAVE_DNS_HERE!$WEAVE_DNS!g" \
        -e "s!INSERT_MAX_REQUEST_SIZE_HERE!$MAX_REQUEST_SIZE!g" \
        > $SERVICES_CONF_TMP
        

## replace old configuration files
cp $SERVICES_CONF_TMP $SERVICES_CONF

# remove temporary files
echo "Removing temporary files"
rm $SERVICES_CONF_TMP

echo "End of Nginx initialization"
