#!/bin/bash

## constants
TOMCAT_VERSION="8.0.24"

TOMCAT_CONF="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/conf/server.xml"
TOMCAT_CONF_TEMPLATE="/templates/server.xml"
TOMCAT_CONF_TMP="/tmp/server.xml"

PLATFORM_CONF="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/conf/bpm-platform.xml"
PLATFORM_CONF_TEMPLATE="/templates/bpm-platform.xml"
PLATFORM_CONF_TMP="/tmp/bpm-platform.xml"

CAMUNDA_WEB_XML="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/camunda/WEB-INF/web.xml"
CAMUNDA_WEB_XML_TEMPLATE="/templates/camunda-web.xml"
CAMUNDA_WEB_XML_TMP="/tmp/camunda-web.xml"

ENGINE_REST_WEB_XML="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/engine-rest/WEB-INF/web.xml"
ENGINE_REST_WEB_XML_TEMPLATE="/templates/engine-rest-web.xml"
ENGINE_REST_WEB_XML_TMP="/tmp/engine-rest-web.xml"

CAMUNDA_ACTIVITYSTREAMS_JAR="camunda-activitystreams.jar"
CAMUNDA_ACTIVITYSTREAMS_PROPS="/templates/activitystreams.properties"
CAMUNDA_ACTIVITYSTREAMS_SRC="/resources/camunda-activitystreams.jar"
CAMUNDA_ACTIVITYSTREAMS_TMP_DIR="/tmp/camunda-activitystreams/"
CAMUNDA_ACTIVITYSTREAMS_DEST="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/lib/camunda-activitystreams.jar"

TOMCAT_SCRIPT="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/bin/catalina.sh"
SETENV_SCRIPT="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/bin/setenv.sh"
TOMCAT_SCRIPT_TMP="/tmp/catalina.sh"

KEYSTORE_DEST="/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/conf/keystore"
KEYSTORE_SRC="/ssl/keystore"

## read environment variables
# check and set default values

if [ -z "$DB_NAME" ]; then
        DB_NAME=camunda-tenant
        echo "ERROR: No database name supplied, using default: $DB_NAME"
fi

if [ -z "$DB_USER" ]; then
        DB_USER=camunda-tenant
        echo "ERROR: No database user supplied, using default: $DB_USER"
fi

if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD=camunda-tenant-pw
        echo "ERROR: No database password supplied, using default: $DB_PASSWORD"
fi

if [ -z "$DB_HOST" ]; then
        DB_HOST=127.0.0.1
        echo "ERROR: No database host supplied, using default: $DB_HOST"
fi

if [ -z "$DB_PORT" ]; then
        DB_PORT=3306
fi

if [ -z "$LDAP_USER" ]; then
        LDAP_USER=cn=admin,dc=tenant,dc=org
        echo "ERROR: No Ldap user supplied, using default: $LDAP_USER"
fi

if [ -z "$LDAP_PASSWORD" ]; then
        LDAP_PASSWORD=tenant-ldap-pw
        echo "ERROR: No Ldap password supplied, using default: $LDAP_PASSWORD"
fi

if [ -z "$LDAP_SERVER" ]; then
        LDAP_SERVER=ldap://127.0.0.1:389
        echo "ERROR: No Ldap server supplied, using default: $LDAP_SERVER"
fi

if [ -z "$LDAP_USER_BASE" ]; then
        LDAP_USER_BASE=ou=people
        echo "WARNING: No Ldap user base supplied, using default: $LDAP_USER_BASE"
fi

if [ -z "$LDAP_BASE_DN" ]; then
        LDAP_BASE_DN=dc=tenant,dc=org
        echo "ERROR: No Ldap base DN supplied, using default: $LDAP_BASE_DN"
fi

if [ -z "$DEFAULT_ADMIN" ]; then
        DEFAULT_ADMIN=admin
        echo "WARNING: No default admin supplied, using default: $DEFAULT_ADMIN"
fi

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

if [ -z "$JAVA_MEM_MIN" ]; then
        JAVA_MEM_MIN=1000M
        echo "WARNING: No JVM memory minimum supplied, using default: $JAVA_MEM_MIN"
fi

if [ -z "$JAVA_MEM_MAX" ]; then
        JAVA_MEM_MAX=2000M
        echo "WARNING: No JVM memory maximum supplied, using default: $JAVA_MEM_MAX"
fi

## replace variables in template

# tomcat database resource
echo "Configuring database"
cat $TOMCAT_CONF_TEMPLATE | sed \
        -e "s/INSERT_DB_NAME_HERE/$DB_NAME/" \
        -e "s/INSERT_DB_USER_HERE/$DB_USER/" \
        -e "s/INSERT_DB_PASSWORD_HERE/$DB_PASSWORD/" \
        -e "s/INSERT_DB_HOST_HERE/$DB_HOST/" \
        -e "s/INSERT_DB_PORT_HERE/$DB_PORT/" \
        > $TOMCAT_CONF_TMP

# LDAP configuration
echo "Configuring LDAP and default admin"
cat $PLATFORM_CONF_TEMPLATE | sed \
        -e "s/INSERT_LDAP_USER_HERE/$LDAP_USER/" \
        -e "s/INSERT_LDAP_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s!INSERT_LDAP_SERVER_HERE!$LDAP_SERVER!" \
        -e "s/INSERT_LDAP_USER_BASE_HERE/$LDAP_USER_BASE/" \
        -e "s/INSERT_LDAP_BASE_DN_HERE/$LDAP_BASE_DN/" \
        -e "s/INSERT_DEFAULT_ADMIN_HERE/$DEFAULT_ADMIN/" \
        > $PLATFORM_CONF_TMP

# CAS configuration
echo "Configuring CAS"
cat $CAMUNDA_WEB_XML_TEMPLATE | sed \
        -e "s!INSERT_CAS_LOGIN_URL_HERE!$CAS_LOGIN_URL!" \
        -e "s!INSERT_CAS_SERVER_URL_HERE!$CAS_SERVER_URL!" \
        -e "s!INSERT_SERVER_NAME_HERE!$SERVER_NAME!" \
        > $CAMUNDA_WEB_XML_TMP

# TODO: not actually armed yet
cp $ENGINE_REST_WEB_XML_TEMPLATE $ENGINE_REST_WEB_XML_TMP


# configure activitystreams plugin
echo "Configuring activitystreams plugin"
mkdir -p $CAMUNDA_ACTIVITYSTREAMS_TMP_DIR
cp $CAMUNDA_ACTIVITYSTREAMS_SRC $CAMUNDA_ACTIVITYSTREAMS_TMP_DIR/$CAMUNDA_ACTIVITYSTREAMS_JAR
cd $CAMUNDA_ACTIVITYSTREAMS_TMP_DIR
# unpack
unzip $CAMUNDA_ACTIVITYSTREAMS_JAR
rm $CAMUNDA_ACTIVITYSTREAMS_JAR
# reconfigure
cat $CAMUNDA_ACTIVITYSTREAMS_PROPS | sed \
        -e "s!INSERT_CAMUNDA_URL_HERE!$CAMUNDA_URL!" \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        > activitystreams.properties
# repackage and insert into Camunda
jar cf $CAMUNDA_ACTIVITYSTREAMS_JAR -C . .
cp $CAMUNDA_ACTIVITYSTREAMS_JAR $CAMUNDA_ACTIVITYSTREAMS_DEST
rm -r $CAMUNDA_ACTIVITYSTREAMS_TMP_DIR


# tomcat configuration
echo "Setting Tomcat Java parameters"
# entropy source
if grep -q "\$JAVA_OPTS -Xms" "$TOMCAT_SCRIPT"; then
  # file already contains custom options
  cat $TOMCAT_SCRIPT | sed \
      's/.*\$JAVA_OPTS -Xms.*/JAVA_OPTS=\"\$JAVA_OPTS -Djava.security.egd=file:\/dev\/.\/urandom\"/' \
      > $TOMCAT_SCRIPT_TMP
else
  # add custom java options
  cat $TOMCAT_SCRIPT | sed \
      "/#!\/bin\/sh/aJAVA_OPTS=\"\$JAVA_OPTS -Djava.security.egd=file:/dev/./urandom\"" \
      > $TOMCAT_SCRIPT_TMP
fi

# memory
echo "Setting Camunda Java parameters"
echo "export CATALINA_OPTS=\"-Xms$JAVA_MEM_MIN -Xmx$JAVA_MEM_MAX\"" > $SETENV_SCRIPT

# insert keystore
echo "Inserting keystore and new configuration files"
cp $KEYSTORE_SRC $KEYSTORE_DEST

## replace old configuration files
cp $TOMCAT_CONF_TMP $TOMCAT_CONF
cp $PLATFORM_CONF_TMP $PLATFORM_CONF
cp $CAMUNDA_WEB_XML_TMP $CAMUNDA_WEB_XML
cp $ENGINE_REST_WEB_XML_TMP $ENGINE_REST_WEB_XML
cp $TOMCAT_SCRIPT_TMP $TOMCAT_SCRIPT

# remove temporary files
echo "Removing temporary files"
rm $TOMCAT_CONF_TMP
rm $PLATFORM_CONF_TMP
rm $CAMUNDA_WEB_XML_TMP
rm $ENGINE_REST_WEB_XML_TMP
rm $TOMCAT_SCRIPT_TMP

echo "End of Camunda initialization"
