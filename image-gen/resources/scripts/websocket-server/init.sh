#!/bin/bash

## constants
WS_CONF="/home/websocket-server/neo4j-websocket-server.properties"
WS_CONF_TEMPLATE="/templates/neo4j-websocket-server.properties"
WS_CONF_TMP="/tmp/neo4j-websocket-server.properties"

SHIN_CONF="/home/websocket-server/shindig-serverroutines.properties"
SHIN_CONF_TEMPLATE="/templates/shindig-serverroutines.properties"
SHIN_CONF_TMP="/tmp/shindig-serverroutines.properties"

START_SCRIPT="/home/websocket-server/websocket-server.sh"
START_SCRIPT_TEMPLATE="/templates/websocket-server.sh"
START_SCRIPT_TMP="/tmp/websocket-server.sh"

## read environment variables
# check and set default values
if [ -z "$THREADS" ]; then
        THREADS=2
        echo "WARNING: No number of server threads supplied, using default: $THREADS"
fi

if [ -z "$ORG_NAME" ]; then
        ORG_NAME="Unnamed Organization"
        echo "WARNING: No organization name supplied, using default: $ORG_NAME"
fi

if [ -z "$ORG_FIELD" ]; then
        ORG_FIELD="none"
        echo "WARNING: No organization field supplied, using default: $ORG_FIELD"
fi

if [ -z "$ORG_SUBFIELD" ]; then
        ORG_SUBFIELD="none"
        echo "WARNING: No organization subfield supplied, using default: $ORG_SUBFIELD"
fi

if [ -z "$ORG_WEBPAGE" ]; then
        ORG_WEBPAGE="about:blank"
        echo "WARNING: No organization website supplied, using default: $ORG_WEBPAGE"
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
# websocket server
echo "Configuring Websocket Server"
cat $WS_CONF_TEMPLATE | sed \
        -e "s/INSERT_THREADS_HERE/$THREADS/" \
        > $WS_CONF_TMP

# shindig server routines
echo "Configuring Shindig Server Routines"
cat $SHIN_CONF_TEMPLATE | sed \
        -e "s/INSERT_ORG_NAME_HERE/$ORG_NAME/" \
        -e "s/INSERT_ORG_FIELD_HERE/$ORG_FIELD/" \
        -e "s/INSERT_ORG_SUBFIELD_HERE/$ORG_SUBFIELD/" \
        -e "s!INSERT_ORG_WEBPAGE_HERE!$ORG_WEBPAGE!" \
        > $SHIN_CONF_TMP

# memory settings
echo "Setting Java parameters"
cat $START_SCRIPT_TEMPLATE | sed \
        -e "s/INSERT_JAVA_MEM_MIN_HERE/$JAVA_MEM_MIN/" \
        -e "s/INSERT_JAVA_MEM_MAX_HERE/$JAVA_MEM_MAX/" \
        > $START_SCRIPT_TMP

## replace old configuration files
echo "Inserting new configuration"
cp $WS_CONF_TMP $WS_CONF
cp $SHIN_CONF_TMP $SHIN_CONF
cp $START_SCRIPT_TMP $START_SCRIPT

# remove temporary files
echo "Removing temporary files"
rm $WS_CONF_TMP
rm $SHIN_CONF_TMP
rm $START_SCRIPT_TMP

echo "End of Open-Xchange initialization"
