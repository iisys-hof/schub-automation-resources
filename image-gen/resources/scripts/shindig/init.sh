#!/bin/bash

## constants
TOKEN_FILE="home/shindig/token.txt"

ES_CONF="/home/shindig/webapps/shindig/WEB-INF/classes/shindig-es-plugin.properties"
ES_CONF_TEMPLATE="/templates/shindig-es-plugin.properties"
ES_CONF_TMP="/tmp/shindig-es-plugin.properties"

SHIN_CONF="/home/shindig/webapps/shindig/WEB-INF/classes/shindig.properties"
SHIN_CONF_TEMPLATE="/templates/shindig.properties"
SHIN_CONF_TMP="/tmp/shindig.properties"

WS_CONF="/home/shindig/webapps/shindig/WEB-INF/classes/websocket-backend.properties"
WS_CONF_TEMPLATE="/templates/websocket-backend.properties"
WS_CONF_TMP="/tmp/websocket-backend.properties"

TOMCAT_SCRIPT="/home/shindig/bin/catalina.sh"
TOMCAT_SCRIPT_TMP="/tmp/catalina.sh"

TOMCAT_CONF="/home/shindig/conf/server.xml"
TOMCAT_CONF_TEMPLATE="/templates/server.xml"

KEYSTORE_DEST="/home/shindig/conf/keystore"
KEYSTORE_SRC="/ssl/keystore"

## read environment variables
# check and set default values
if [ -z "$SEC_TOKEN" ]; then
        SEC_TOKEN=AAAAAAAAAAAA/AAAAAAAAAAAAAAAAAA/AAAAAAAAAA=
        echo "WARNING: No security token supplied, using default: $SEC_TOKEN"
fi

if [ -z "$ES_HOST" ]; then
        ES_HOST=127.0.0.1
        echo "WARNING: No Elasticsearch host supplied, using default: $ES_HOST"
fi

if [ -z "$ES_PORT" ]; then
        ES_HOST=9300
fi

if [ -z "$WS_SERVER" ]; then
        WS_SERVER=127.0.0.1:8081
        echo "ERROR: No Websocket Server supplied, using default: $WS_SERVER"
fi

if [ -z "$WS_CONNECTIONS" ]; then
        WS_CONNECTIONS=2
        echo "WARNING: No number of websocket connections supplied, using default: $WS_CONNECTIONS"
fi

if [ -z "$JAVA_MEM_MIN" ]; then
        JAVA_MEM_MIN=1000M
        echo "WARNING: No JVM memory minimum supplied, using default: $JAVA_MEM_MIN"
fi

if [ -z "$JAVA_MEM_MAX" ]; then
        JAVA_MEM_MAX=2000M
        echo "WARNING: No JVM memory maximum supplied, using default: $JAVA_MEM_MAX"
fi

## replace variables in templates
# set security token
echo "Setting security token"
echo $SEC_TOKEN > $TOKEN_FILE

# elasticsearch plugin
echo "Configuring Elasticsearch plugin"
cat $ES_CONF_TEMPLATE | sed \
        -e "s/INSERT_ES_HOST_HERE/$ES_HOST/" \
        -e "s/INSERT_ES_PORT_HERE/$ES_PORT/" \
        -e "s/INSERT_ES_CLUSTER_NAME_HERE/$ES_CLUSTER_NAME/" \
        > $ES_CONF_TMP

# websocket backend
echo "Configuring Websocket Backend"
cat $WS_CONF_TEMPLATE | sed \
        -e "s/INSERT_WS_SERVER_HERE/$WS_SERVER/" \
        -e "s/INSERT_WS_CONNECTIONS_HERE/$WS_CONNECTIONS/" \
        > $WS_CONF_TMP

# shindig configuration
# TODO?

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
cp $ES_CONF_TMP $ES_CONF
#cp $SHIN_CONF_TMP $SHIN_CONF
cp $WS_CONF_TMP $WS_CONF
cp $TOMCAT_SCRIPT_TMP $TOMCAT_SCRIPT
cp $TOMCAT_CONF_TEMPLATE $TOMCAT_CONF

# remove temporary files
echo "Removing temporary files"
rm $ES_CONF_TMP
#rm $SHIN_CONF_TMP
rm $WS_CONF_TMP
rm $TOMCAT_SCRIPT_TMP

echo "End of Apache Shindig initialization"
