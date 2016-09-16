#!/bin/bash

# TODO: proper SSL configuration

## constants
CAS_CONF="/home/cas/webapps/cas/WEB-INF/cas.properties"
CAS_CONF_TEMPLATE="/templates/cas.properties"
CAS_CONF_TMP="/tmp/cas.properties"

DEPL_CONF="/home/cas/webapps/cas/WEB-INF/deployerConfigContext.xml"
DEPL_CONF_TEMPLATE="/templates/deployerConfigContext.xml"
DEPL_CONF_TMP="/tmp/deployerConfigContext.xml"

TOMCAT_SCRIPT="/home/cas/bin/catalina.sh"
TOMCAT_SCRIPT_TMP="/tmp/catalina.sh"

TOMCAT_CONF="/home/cas/conf/server.xml"
TOMCAT_CONF_TEMPLATE="/templates/server.xml"

KEYSTORE_DEST="/home/cas/conf/keystore"
KEYSTORE_SRC="/ssl/keystore"

## read environment variables
# check and set default values

if [ -z "$SERVER_NAME" ]; then
        SERVER_NAME=https://tenant.schub.de
        echo "ERROR: No server name supplied, using default: $SERVER_NAME"
fi

if [ -z "$NODE_NAME" ]; then
        NODE_NAME=cas01.tenant.schub
        echo "WARNING: No node name supplied, using default: $NODE_NAME"
fi

if [ -z "$PWD_CHANGE_URL" ]; then
        PWD_CHANGE_URL=$SERVER_NAME/change_password
        echo "WARNING: No password change url supplied, using default: $PWD_CHANGE_URL"
fi

if [ -z "$LDAP_SERVER" ]; then
        LDAP_SERVER=ldap://127.0.0.1:389
        echo "ERROR: No Ldap server supplied, using default: $LDAP_SERVER"
fi

if [ -z "$LDAP_USER" ]; then
        LDAP_USER=cn=admin,dc=tenant,dc=org
        echo "ERROR: No Ldap user supplied, using default: $LDAP_USER"
fi

if [ -z "$LDAP_PASSWORD" ]; then
        LDAP_PASSWORD=secret
        echo "ERROR: No Ldap password supplied, using default: $LDAP_PASSWORD"
fi

if [ -z "$USER_BASE_DN" ]; then
        USER_BASE_DN=ou=users,ou=accounts,dc=tenant,dc=org
        echo "ERROR: No Ldap user base DN supplied, using default: $USER_BASE_DN"
fi

if [ -z "$ALLOWED_SERVICE_IDS" ]; then
        ALLOWED_SERVICE_IDS="^(http?|https?)://.*"
        echo "WARNING: No allowed service IDs supplied, using default: $ALLOWED_SERVICE_IDS"
fi

if [ -z "$LIFERAY_PGT_CALLBACK" ]; then
        LIFERAY_PGT_CALLBACK=https://tenant.schub.de/CASClearPass/pgtCallback
        echo "WARNING: No Liferay PGT-Callback url supplied, using default: $LIFERAY_PGT_CALLBACK"
fi

if [ -z "$OX_PGT_CALLBACK" ]; then
        OX_PGT_CALLBACK=https://tenant.schub.de/appsuite/api/cascallback
        echo "WARNING: No Open-Xchange PGT-Callback url supplied, using default: $OX_PGT_CALLBACK"
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
echo "Configuring server and ldap"
cat $CAS_CONF_TEMPLATE | sed \
        -e "s!INSERT_SERVER_NAME_HERE!$SERVER_NAME!" \
        -e "s/INSERT_NODE_NAME_HERE/$NODE_NAME/" \
        -e "s!INSERT_PWD_CHANGE_URL_HERE!$PWD_CHANGE_URL!" \
        -e "s!INSERT_LDAP_SERVER_HERE!$LDAP_SERVER!" \
        -e "s/INSERT_LDAP_USER_HERE/$LDAP_USER/" \
        -e "s/INSERT_LDAP_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s/INSERT_USER_BASE_DN_HERE/$USER_BASE_DN/" \
        > $CAS_CONF_TMP

echo "Configuring allowed services"
cat $DEPL_CONF_TEMPLATE | sed \
        -e "s!INSERT_ALLOWED_SERVICE_IDS_HERE!$ALLOWED_SERVICE_IDS!" \
        -e "s!INSERT_LIFERAY_PGT_CALLBACK_HERE!$LIFERAY_PGT_CALLBACK!" \
        -e "s!INSERT_OX_PGT_CALLBACK_HERE!$OX_PGT_CALLBACK!" \
        > $DEPL_CONF_TMP

# tomcat configuration
echo "Setting Tomcat Java options"
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
echo "Inserting keystore and  new configuration files"
cp $KEYSTORE_SRC $KEYSTORE_DEST

## replace old configuration files
cp $CAS_CONF_TMP $CAS_CONF
cp $DEPL_CONF_TMP $DEPL_CONF
cp $TOMCAT_SCRIPT_TMP $TOMCAT_SCRIPT
cp $TOMCAT_CONF_TEMPLATE $TOMCAT_CONF

# remove temporary files
echo "Removing temporary files"
rm $CAS_CONF_TMP
rm $DEPL_CONF_TMP
rm $TOMCAT_SCRIPT_TMP

echo "End of CAS initialization"
