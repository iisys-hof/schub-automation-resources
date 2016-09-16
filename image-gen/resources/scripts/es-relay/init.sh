#!/bin/bash

## constants
ES_RELAY_CONF="/home/es-relay/webapps/es-relay/WEB-INF/classes/elasticsearch-relay.properties"
ES_RELAY_CONF_TEMPLATE="/templates/elasticsearch-relay.properties"
ES_RELAY_CONF_TMP="/tmp/elasticsearch-relay.properties"

WEB_XML="/home/es-relay/webapps/es-relay/WEB-INF/web.xml"
WEB_XML_TEMPLATE="/templates/web.xml"
WEB_XML_TMP="/tmp/web.xml"

TOMCAT_SCRIPT="/home/es-relay/bin/catalina.sh"
TOMCAT_SCRIPT_TMP="/tmp/catalina.sh"

TOMCAT_CONF="/home/es-relay/conf/server.xml"
TOMCAT_CONF_TEMPLATE="/templates/server.xml"

KEYSTORE_DEST="/home/es-relay/conf/keystore"
KEYSTORE_SRC="/ssl/keystore"

## read environment variables
# check and set default values
# Elasticsearch 1.x
if [ -z "$ES_URL" ]; then
        ES_URL=http://127.0.0.1:9200/
        echo "WARNING: No Elasticsearch 1.x URL supplied, using default: $ES_URL"
fi

# TODO: are port, host and name even required?
if [ -z "$ES_HOST" ]; then
        ES_HOST=127.0.0.1
        echo "WARNING: No Elasticsearch 1.x host supplied, using default: $ES_HOST"
fi

if [ -z "$ES_PORT" ]; then
        ES_PORT=9300
fi

if [ -z "$ES_CLUSTER_NAME" ]; then
        ES_CLUSTER_NAME=tenant-x-cluster
        echo "WARNING: No Elasticsearch 1.x cluster name supplied, using default: $ES_CLUSTER_NAME"
fi

# Elasticsearch 2.x
if [ -z "$ES2_URL" ]; then
        ES2_URL=http://127.0.0.1:9201/
        echo "WARNING: No Elasticsearch 2.x URL supplied, using default: $ES2_URL"
fi

# TODO: are port, host and name even required?
if [ -z "$ES2_HOST" ]; then
        ES2_HOST=127.0.0.1
        echo "WARNING: No Elasticsearch 2.x host supplied, using default: $ES2_HOST"
fi

if [ -z "$ES2_PORT" ]; then
        ES2_PORT=9301
fi

if [ -z "$ES2_CLUSTER_NAME" ]; then
        ES2_CLUSTER_NAME=tenant-x-cluster2
        echo "WARNING: No Elasticsearch 2.x cluster name supplied, using default: $ES2_CLUSTER_NAME"
fi

# Liferay
if [ -z "$LIFERAY_INDEX" ]; then
        LIFERAY_INDEX=liferay-20116
        echo "WARNING: No Liferay index name supplied, using default: $LIFERAY_INDEX"
fi

if [ -z "$LIFERAY_URL" ]; then
        LIFERAY_URL=http://127.0.0.1:8080/
        echo "WARNING: No Liferay URL supplied, using default: $LIFERAY_URL"
fi

if [ -z "$LIFERAY_COMPANY_ID" ]; then
        LIFERAY_COMPANY_ID=20116
        echo "WARNING: No Liferay company ID supplied, using default: $LIFERAY_COMPANY_ID"
fi

if [ -z "$LIFERAY_USER" ]; then
        LIFERAY_USER=admin
        echo "WARNING: No Liferay user supplied, using default: $LIFERAY_USER"
fi

if [ -z "$LIFERAY_PASSWORD" ]; then
        LIFERAY_PASSWORD=admin
        echo "WARNING: No Liferay password supplied, using default: $LIFERAY_PASSWORD"
fi

if [ -z "$LIFERAY_PASS_ROLES" ]; then
        LIFERAY_PASS_ROLES=20208,20211
        echo "WARNING: No Liferay passthrough roles supplied, using default: $LIFERAY_PASS_ROLES"
fi

# Nuxeo
if [ -z "$NUXEO_URL" ]; then
        NUXEO_URL=http://127.0.0.1:8080/nuxeo/
        echo "WARNING: No Nuxeo URL supplied, using default: $NUXEO_URL"
fi

if [ -z "$NUXEO_USER" ]; then
        NUXEO_USER=Administrator
        echo "WARNING: No Nuxeo user supplied, using default: $NUXEO_USER"
fi

if [ -z "$NUXEO_PASSWORD" ]; then
        NUXEO_PASSWORD=Administrator
        echo "WARNING: No Nuxeo password supplied, using default: $NUXEO_PASSWORD"
fi

# Shindig
if [ -z "$SHINDIG_URL" ]; then
        SHINDIG_URL=http://127.0.0.1:8080/shindig/
        echo "WARNING: No Nuxeo URL supplied, using default: $SHINDIG_URL"
fi

# CAS
if [ -z "$CAS_LOGIN_URL" ]; then
        CAS_LOGIN_URL=https://127.0.0.1/cas/login
        echo "ERROR: No CAS login url supplied, using default: $CAS_LOGIN_URL"
fi

if [ -z "$CAS_SERVER_URL" ]; then
        CAS_SERVER_URL=https://127.0.0.1/cas/
        echo "ERROR: No CAS server url supplied, using default: $CAS_SERVER_URL"
fi

if [ -z "$SERVER_NAME" ]; then
        SERVER_NAME=https://127.0.0.1
        echo "ERROR: No server name supplied, using default: $SERVER_NAME"
fi

# Tomcat Memory
if [ -z "$JAVA_MEM_MIN" ]; then
        JAVA_MEM_MIN=256M
        echo "WARNING: No JVM memory minimum supplied, using default: $JAVA_MEM_MIN"
fi

if [ -z "$JAVA_MEM_MAX" ]; then
        JAVA_MEM_MAX=512M
        echo "WARNING: No JVM memory maximum supplied, using default: $JAVA_MEM_MAX"
fi

## replace variables in templates
echo "Configuring Elasticsearch Relay"
cat $ES_RELAY_CONF_TEMPLATE | sed \
        -e "s!INSERT_ES_URL_HERE!$ES_URL!" \
        -e "s/INSERT_ES_HOST_HERE/$ES_HOST/" \
        -e "s/INSERT_ES_PORT_HERE/$ES_PORT/" \
        -e "s!INSERT_ES2_URL_HERE!$ES2_URL!" \
        -e "s/INSERT_ES2_HOST_HERE/$ES2_HOST/" \
        -e "s/INSERT_ES2_PORT_HERE/$ES2_PORT/" \
        -e "s/INSERT_LIFERAY_INDEX_HERE/$LIFERAY_INDEX/" \
        -e "s!INSERT_LIFERAY_URL_HERE!$LIFERAY_URL!" \
        -e "s/INSERT_LIFERAY_COMPANY_ID_HERE/$LIFERAY_COMPANY_ID/" \
        -e "s/INSERT_LIFERAY_USER_HERE/$LIFERAY_USER/" \
        -e "s/INSERT_LIFERAY_PASSWORD_HERE/$LIFERAY_PASSWORD/" \
        -e "s/INSERT_LIFERAY_PASS_ROLES_HERE/$LIFERAY_PASS_ROLES/" \
        -e "s!INSERT_NUXEO_URL_HERE!$NUXEO_URL!" \
        -e "s/INSERT_NUXEO_USER_HERE/$NUXEO_USER/" \
        -e "s/INSERT_NUXEO_PASSWORD_HERE/$NUXEO_PASSWORD/" \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        > $ES_RELAY_CONF_TMP

# configure CAS filter in web.xml
echo "Configuring CAS"
cat $WEB_XML_TEMPLATE | sed \
        -e "s!INSERT_CAS_LOGIN_URL_HERE!$CAS_LOGIN_URL!" \
        -e "s!INSERT_CAS_SERVER_URL_HERE!$CAS_SERVER_URL!" \
        -e "s!INSERT_SERVER_NAME_HERE!$SERVER_NAME!" \
        > $WEB_XML_TMP

# tomcat configuration
echo "Configuring Tomcat Java paremters"
if grep -q "\$JAVA_OPTS -Xms" "$TOMCAT_SCRIPT"; then
  # file already contains custom options
  cat $TOMCAT_SCRIPT | sed \
      's/.*\$JAVA_OPTS -Xms.*/JAVA_OPTS=\"\$JAVA_OPTS -Xms$JAVA_MEM_MIN -Xmx$JAVA_MEM_MAX -Djava.security.egd=file:\/dev\/.\/urandom\"/' \
      > $TOMCAT_SCRIPT_TMP
else
  # add custom java options
  cat $TOMCAT_SCRIPT | sed \
      "/#!\/bin\/sh/aJAVA_OPTS=\"\$JAVA_OPTS -Xms$JAVA_MEM_MIN -Xmx$JAVA_MEM_MAX -Djava.security.egd=file:/dev/./urandom\"" \
      > $TOMCAT_SCRIPT_TMP
fi

# insert keystore
echo "Inserting keystore and new configuration files"
cp $KEYSTORE_SRC $KEYSTORE_DEST

## replace old configuration files
cp $ES_RELAY_CONF_TMP $ES_RELAY_CONF
cp $TOMCAT_SCRIPT_TMP $TOMCAT_SCRIPT
cp $WEB_XML_TMP $WEB_XML
cp $TOMCAT_CONF_TEMPLATE $TOMCAT_CONF

# remove temporary files
echo "Removing temporary files"
rm $ES_WRAPPER_CONF_TMP
rm $WEB_XML_TMP
rm $TOMCAT_SCRIPT_TMP

echo "End of Elasticsearch Wrapper initialization"
