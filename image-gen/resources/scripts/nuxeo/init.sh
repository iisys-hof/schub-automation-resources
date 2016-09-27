#!/bin/bash

## constants
NX_CONF="/etc/nuxeo/nuxeo.conf"
NX_CONF_TEMPLATE="/templates/nuxeo.conf"
NX_CONF_TMP="/tmp/nuxeo.conf"

CAS_CONF="/var/lib/nuxeo/server/nxserver/config/CAS2-config.xml"
CAS_CONF_TEMPLATE="/templates/CAS2-config.xml"
CAS_CONF_TMP="/tmp/CAS2-config.xml"

ACTIVITYSTREAMS_JAR="nuxeo-activitystreams.jar"
ACTIVITYSTREAMS_PROPS="/templates/activitystreams.properties"
ACTIVITYSTREAMS_SRC="/resources/nuxeo-activitystreams.jar"
ACTIVITYSTREAMS_TMP_DIR="/tmp/nuxeo-activitystreams/"
ACTIVITYSTREAMS_DEST="/var/lib/nuxeo/server/nxserver/plugins/nuxeo-activitystreams.jar"

CAMUNDA_OPS_JAR="nuxeo-camunda-operations.jar"
CAMUNDA_OPS_PROPS="/templates/camunda-operations.properties"
CAMUNDA_OPS_SRC="/resources/nuxeo-camunda-operations.jar"
CAMUNDA_OPS_TMP_DIR="/tmp/camunda-operations/"
CAMUNDA_OPS_DEST="/var/lib/nuxeo/server/nxserver/plugins/nuxeo-camunda-operations.jar"

KEYSTORE_DEST="/var/lib/nuxeo/server/conf/keystore"
KEYSTORE_SRC="/ssl/keystore"

## read environment variables
# check and set default values

# main configuration
if [ -z "$JAVA_MEM_MIN" ]; then
        JAVA_MEM_MIN=1000M
        echo "WARNING: No JVM memory minimum supplied, using default: $JAVA_MEM_MIN"
fi

if [ -z "$JAVA_MEM_MAX" ]; then
        JAVA_MEM_MAX=3000M
        echo "WARNING: No JVM memory maximum supplied, using default: $JAVA_MEM_MAX"
fi

if [ -z "$NUXEO_URL" ]; then
        NUXEO_URL=http://127.0.0.1:8080/nuxeo/
        echo "WARNING: No Nuxeo url supplied, using default: $NUXEO_URL"
fi

if [ -z "$DB_NAME" ]; then
        DB_NAME=nuxeo_tenant
        echo "ERROR: No database name supplied, using default: $DB_NAME"
fi

if [ -z "$DB_USER" ]; then
        DB_USER=nuxeo-tenant
        echo "ERROR: No database user supplied, using default: $DB_USER"
fi

if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD=nuxeo-tenant-pw
        echo "ERROR: No database password supplied, using default: $DB_USER"
fi

if [ -z "$DB_HOST" ]; then
        DB_HOST=127.0.0.1
        echo "ERROR: No database host supplied, using default: $DB_HOST"
fi

if [ -z "$DB_PORT" ]; then
        DB_PORT=3306
fi

if [ -z "$ES_SERVER" ]; then
        ES_SERVER=127.0.0.1:9300
        echo "ERROR: No Elasticsearch server supplied, using default: $ES_SERVER"
fi

if [ -z "$ES_CLUSTER_NAME" ]; then
        ES_CLUSTER_NAME=tenant-x-cluster
        echo "WARNING: No Elasticsearch cluster name supplied, using default: $ES_CLUSTER_NAME"
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
        LDAP_USER_BASE=ou=people,dc=tenant,dc=org
        echo "ERROR: No Ldap user base supplied, using default: $LDAP_USER_BASE"
fi

# CAS configuration
if [ -z "$CAS_APP_URL" ]; then
        CAS_APP_URL=http://127.0.0.1:8080/nuxeo/nxstartup.faces
        echo "ERROR: No CAS application url supplied, using default: $CAS_APP_URL"
fi

if [ -z "$CAS_SVC_LOGIN_URL" ]; then
        CAS_SVC_LOGIN_URL=http://127.0.0.1:8080/cas/login
        echo "ERROR: No CAS login url supplied, using default: $CAS_SVC_LOGIN_URL"
fi

if [ -z "$CAS_SVC_VALIDATE_URL" ]; then
        CAS_SVC_VALIDATE_URL=http://127.0.0.1:8080/cas/serviceValidate
        echo "ERROR: No CAS service validation url supplied, using default: $CAS_SVC_VALIDATE_URL"
fi

if [ -z "$CAS_LOGOUT_URL" ]; then
        CAS_LOGOUT_URL=http://127.0.0.1:8080/cas/logout
        echo "ERROR: No CAS logout url supplied, using default: $CAS_LOGOUT_URL"
fi

# misc plugin configuration

if [ -z "$SHINDIG_URL" ]; then
        SHINDIG_URL=http://127.0.0.1:8080/shindig/
        echo "WARNING: No Shindig url supplied, using default: $SHINDIG_URL"
fi

if [ -z "$ACTIVITY_LANG" ]; then
        ACTIVITY_LANG=de
        echo "WARNING: No activity language supplied, using default: $ACTIVITY_LANG"
fi

if [ -z "$CAMUNDA_URL" ]; then
        CAMUNDA_URL=http://127.0.0.1:8080/camunda/
        echo "WARNING: No Camunda url supplied, using default: $CAMUNDA_URL"
fi

if [ -z "$CAMUNDA_REST_URL" ]; then
        CAMUNDA_REST_URL=http://127.0.0.1:8080/engine-rest/
        echo "WARNING: No Camunda Rest url supplied, using default: $CAMUNDA_REST_URL"
fi

if [ -z "$BPMN_JS_UTILS_URL" ]; then
        BPMN_JS_UTILS_URL=http://127.0.0.1/bpmn-js-utils
        echo "WARNING: No bpmn javascript utilities url supplied, using default: $BPMN_JS_UTILS_URL"
fi

if [ -z "$PROCESS_BASE_URL" ]; then
        PROCESS_BASE_URL=http://127.0.0.1:8084
        echo "WARNING: No camunda processes base url supplied, using default: $PROCESS_BASE_URL"
fi

if [ -z "$PROFILE_URL" ]; then
        PROFILE_URL=http://127.0.0.1:8080/web/guest/profile?userId=
        echo "WARNING: No profile base url supplied, using default: $PROFILE_URL"
fi

## replace variables in template

# main configuration
echo "Configuring Nuxeo"
cat $NX_CONF_TEMPLATE | sed \
        -e "s/INSERT_JAVA_MEM_MIN_HERE/$JAVA_MEM_MIN/" \
        -e "s/INSERT_JAVA_MEM_MAX_HERE/$JAVA_MEM_MAX/" \
        -e "s!INSERT_NUXEO_URL_HERE!$NUXEO_URL!" \
        -e "s/INSERT_DB_NAME_HERE/$DB_NAME/" \
        -e "s/INSERT_DB_USER_HERE/$DB_USER/" \
        -e "s/INSERT_DB_PASSWORD_HERE/$DB_PASSWORD/" \
        -e "s/INSERT_DB_HOST_HERE/$DB_HOST/" \
        -e "s/INSERT_DB_PORT_HERE/$DB_PORT/" \
        -e "s/INSERT_ES_SERVER_HERE/$ES_SERVER/" \
        -e "s/INSERT_ES_CLUSTER_NAME_HERE/$ES_CLUSTER_NAME/" \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        -e "s/INSERT_LDAP_USER_HERE/$LDAP_USER/" \
        -e "s/INSERT_LDAP_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s!INSERT_LDAP_SERVER_HERE!$LDAP_SERVER!" \
        -e "s/INSERT_LDAP_USER_BASE_HERE/$LDAP_USER_BASE/" \
        > $NX_CONF_TMP

# CAS configuration
echo "Configuring CAS"
cat $CAS_CONF_TEMPLATE | sed \
        -e "s!INSERT_CAS_APP_URL_HERE!$CAS_APP_URL!" \
        -e "s!INSERT_CAS_SVC_LOGIN_URL_HERE!$CAS_SVC_LOGIN_URL!" \
        -e "s!INSERT_CAS_SVC_VALIDATE_URL_HERE!$CAS_SVC_VALIDATE_URL!" \
        -e "s!INSERT_CAS_LOGOUT_URL_HERE!$CAS_LOGOUT_URL!" \
        > $CAS_CONF_TMP


# Activitystreams configuration
echo "Configuring activitystreams plugin"
mkdir -p $ACTIVITYSTREAMS_TMP_DIR
cd $ACTIVITYSTREAMS_TMP_DIR
cp $ACTIVITYSTREAMS_SRC $ACTIVITYSTREAMS_TMP_DIR/$ACTIVITYSTREAMS_JAR
# unpack
unzip $ACTIVITYSTREAMS_JAR
rm $ACTIVITYSTREAMS_JAR
# reconfigure
cat $ACTIVITYSTREAMS_PROPS | sed \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        -e "s!INSERT_NUXEO_URL_HERE!$NUXEO_URL!" \
        -e "s!INSERT_ACTIVITY_LANG_HERE!$ACTIVITY_LANG!" \
        > activitystreams.properties
# repackage and insert into Nuxeo
jar cmf META-INF/MANIFEST.MF $ACTIVITYSTREAMS_JAR -C . .
cp $ACTIVITYSTREAMS_JAR $ACTIVITYSTREAMS_DEST
rm -r $ACTIVITYSTREAMS_TMP_DIR


# Camunda Operations
echo "Configuring Camunda operations"
mkdir -p $CAMUNDA_OPS_TMP_DIR
cd $CAMUNDA_OPS_TMP_DIR
cp $CAMUNDA_OPS_SRC $CAMUNDA_OPS_TMP_DIR/$CAMUNDA_OPS_JAR
# unpack
unzip $CAMUNDA_OPS_JAR
rm $CAMUNDA_OPS_JAR
# reconfigure
cat $CAMUNDA_OPS_PROPS | sed \
        -e "s!INSERT_CAMUNDA_REST_URL_HERE!$CAMUNDA_REST_URL!" \
        > camunda-operations.properties
# repackage and insert into Nuxeo
jar cmf META-INF/MANIFEST.MF $CAMUNDA_OPS_JAR -C . .
cp $CAMUNDA_OPS_JAR $CAMUNDA_OPS_DEST
rm -r $CAMUNDA_OPS_TMP_DIR


# insert keystore
echo "Inserting keystore and new configuration files"
cp $KEYSTORE_SRC $KEYSTORE_DEST

## replace old configuration files
cp $NX_CONF_TMP $NX_CONF
cp $CAS_CONF_TMP $CAS_CONF

# remove temporary files
echo "Removing temporary files"
rm $NX_CONF_TMP
rm $CAS_CONF_TMP

# fix permissions
echo "Fixing permissions for user nuxeo"
chown -R nuxeo:nuxeo /var/lib/nuxeo/data/

echo "End of Nuxeo initialization"
