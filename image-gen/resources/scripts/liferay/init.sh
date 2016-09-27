#!/bin/bash

## constants
TOMCAT_VERSION="8.0.32"

LR_CONF="/home/liferay/portal-ext.properties"
LR_CONF_TEMPLATE="/templates/portal-ext.properties"
LR_CONF_TMP="/tmp/portal-ext.properties"

LDAP_CONF="/home/liferay/osgi/configs/com.liferay.portal.security.ldap.configuration.LDAPServerConfiguration-0.cfg"
LDAP_CONF_TEMPLATE="/templates/ldap-server-config.cfg"
LDAP_CONF_TMP="/tmp/ldap-server-config.cfg"

LDAP_AUTH_CONF="/home/liferay/osgi/configs/com.liferay.portal.security.ldap.authenticator.configuration.LDAPAuthConfiguration-0.cfg"
LDAP_AUTH_CONF_TEMPLATE="/templates/ldap-auth-config.cfg"

LDAP_IMPORT_CONF="/home/liferay/osgi/configs/com.liferay.portal.security.ldap.exportimport.configuration.LDAPImportConfiguration-0.cfg"
LDAP_IMPORT_CONF_TEMPLATE="/templates/ldap-import-config.cfg"

CMIS_CONF="/home/liferay/osgi/configs/com.liferay.portal.store.cmis.configuration.CMISStoreConfiguration.cfg"
CMIS_CONF_TEMPLATE="/templates/cmis-store-config.cfg"
CMIS_CONF_TMP="/tmp/cmis-store-config.cfg"

ES_CONF="/home/liferay/osgi/configs/com.liferay.portal.search.elasticsearch.configuration.ElasticsearchConfiguration.cfg"
ES_CONF_TEMPLATE="/templates/elasticsearch-config.cfg"
ES_CONF_TMP="/tmp/elasticsearch-config.cfg"

BAS_AUTH_VER_CONF="/home/liferay/osgi/configs/com.liferay.portal.security.auth.verifier.basic.auth.header.module.configuration.BasicAuthHeaderAuthVerifierConfiguration-0.cfg"
BAS_AUTH_VER_CONF_TEMPLATE="/templates/basic-auth-ver-config.cfg"

DIG_AUTH_VER_CONF="/home/liferay/osgi/configs/com.liferay.portal.security.auth.verifier.digest.authentication.module.configuration.DigestAuthenticationAuthVerifierConfiguration-0.cfg"
DIG_AUTH_VER_CONF_TEMPLATE="/templates/digest-auth-ver-config.cfg"

POR_SESS_AUTH_VER_CONF="/home/liferay/osgi/configs/com.liferay.portal.security.auth.verifier.portal.session.module.configuration.PortalSessionAuthVerifierConfiguration-0.cfg"
POR_SESS_AUTH_VER_CONF_TEMPLATE="/templates/portal-session-auth-ver-config.cfg"

ACTIVITYSTREAMS_JAR="activitystreams.mod-1.0.0.jar"
ACTIVITYSTREAMS_PROPS="/templates/shindig-activitystreams.properties"
ACTIVITYSTREAMS_SRC="/resources/activitystreams.mod-1.0.0.jar"
ACTIVITYSTREAMS_TMP_DIR="/tmp/activitystreams/"
ACTIVITYSTREAMS_DEST="/home/liferay/deploy/activitystreams.mod-1.0.0.jar"

CAS_CLEARPASS_JAR="casclearpassws-1.0.0.jar"
CAS_CLEARPASS_PROPS="/templates/cas_autologin.properties"
CAS_CLEARPASS_PORTAL_PROPS="/templates/cas_autologin_portal.properties"
CAS_CLEARPASS_SRC="/resources/casclearpassws-1.0.0.jar"
CAS_CLEARPASS_TMP_DIR="/tmp/CASClearPass/"
CAS_CLEARPASS_DEST="/home/liferay/deploy/casclearpassws-1.0.0.jar"

SHINDIG_TOKEN_FILE="/home/liferay/token.txt"

SHINDIG_PORTLETS_WAR="shindig-7.0.1.war"
SHINDIG_PORTLETS_PROPS="/templates/shindig-portlet.properties"
SHINDIG_PORTLETS_SRC="/resources/shindig-7.0.1.war"
SHINDIG_PORTLETS_TMP_DIR="/tmp/shindig-portlets/"
SHINDIG_PORTLETS_DEST="/home/liferay/deploy/shindig-7.0.1.war"

ASSET_EXPORT_WAR="AssetExportTool-7.0.1-ga2.war"
ASSET_EXPORT_PROPS="/templates/asset-export-portlet.properties"
ASSET_EXPORT_SRC="/resources/AssetExportTool-7.0.1-ga2.war"
ASSET_EXPORT_TMP_DIR="/tmp/asset-export-tool/"
ASSET_EXPORT_DEST="/home/liferay/deploy/AssetExportTool-7.0.1-ga2.war"

SOCIAL_MESSENGER_WAR="SocialMessenger-7.0.1-ga2.war"
SOCIAL_MESSENGER_PROPS="/templates/social-messenger-portlet.properties"
SOCIAL_MESSENGER_SRC="/resources/SocialMessenger-7.0.1-ga2.war"
SOCIAL_MESSENGER_TMP_DIR="/tmp/social-messenger/"
SOCIAL_MESSENGER_DEST="/home/liferay/deploy/SocialMessenger-7.0.1-ga2.war"

# TODO: Corporate Search

TOMCAT_SCRIPT="/home/liferay/tomcat-$TOMCAT_VERSION/bin/catalina.sh"
TOMCAT_SCRIPT_TMP="/tmp/catalina.sh"

TOMCAT_CONF="/home/liferay/tomcat-$TOMCAT_VERSION/conf/server.xml"
TOMCAT_CONF_TEMPLATE="/templates/server.xml"

KEYSTORE_DEST="/home/liferay/tomcat-$TOMCAT_VERSION/conf/keystore"
KEYSTORE_SRC="/ssl/keystore"

## read environment variables
# check and set default values

# main configuration
if [ -z "$LIFERAY_URL" ]; then
        LIFERAY_URL=http://127.0.0.1:8080
        echo "WARNING: No Liferay url supplied, using default: $LIFERAY_URL"
fi

if [ -z "$ADMIN_MAIL" ]; then
        ADMIN_MAIL=admin@localhost.de
        echo "WARNING: No admin e-mail address supplied, using default: $ADMIN_MAIL"
fi

if [ -z "$ADMIN_FULL_NAME" ]; then
        ADMIN_FULL_NAME="Admin Admin"
        echo "WARNING: No full name supplied for admin, using default: $ADMIN_FULL_NAME"
fi

if [ -z "$ADMIN_FIRST_NAME" ]; then
        ADMIN_FIRST_NAME=Admin
        echo "WARNING: No first name supplied for admin, using default: $ADMIN_FIRST_NAME"
fi

if [ -z "$ADMIN_LAST_NAME" ]; then
        ADMIN_LAST_NAME=Admin
        echo "WARNING: No last name supplied for admin, using default: $ADMIN_LAST_NAME"
fi

if [ -z "$ADMIN_PASSWORD" ]; then
        ADMIN_PASSWORD=admin
        echo "ERROR: No admin password supplied, using default: $ADMIN_PASSWORD"
fi

if [ -z "$ADMIN_ID" ]; then
        ADMIN_ID=admin
        echo "WARNING: No admin ID supplied, using default: $ADMIN_ID"
fi

if [ -z "$COMPANY_NAME" ]; then
        COMPANY_NAME="Demo Company"
        echo "WARNING: No company name supplied, using default: $COMPANY_NAME"
fi

if [ -z "$COMPANY_WEBID" ]; then
        COMPANY_WEBID=demo.schub.de
        echo "WARNING: No company web ID supplied, using default: $COMPANY_WEBID"
fi

if [ -z "$COMPANY_LOCALE" ]; then
        COMPANY_LOCALE=de_DE
        echo "WARNING: No company locale supplied, using default: $COMPANY_LOCALE"
fi

if [ -z "$COMPANY_TIMEZONE" ]; then
        COMPANY_TIMEZONE=Europe/Berlin
        echo "WARNING: No company timezone supplied, using default: $COMPANY_TIMEZONE"
fi

if [ -z "$USER_COUNTRY" ]; then
        USER_COUNTRY=DE
        echo "WARNING: No user country supplied, using default: $USER_COUNTRY"
fi

if [ -z "$USER_LANGUAGE" ]; then
        USER_LANGUAGE=de
        echo "WARNING: No user language supplied, using default: $USER_LANGUAGE"
fi

if [ -z "$DB_USER" ]; then
        DB_USER=liferay_demo
        echo "ERROR: No database user supplied, using default: $DB_USER"
fi

if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD=liferay-demo-pw
        echo "ERROR: No database password supplied, using default: $DB_PASSWORD"
fi

if [ -z "$DB_SERVER" ]; then
        DB_SERVER=127.0.0.1:3306
        echo "ERROR: No database server supplied, using default: $DB_SERVER"
fi

if [ -z "$DB_NAME" ]; then
        DB_NAME=liferay_demo
        echo "ERROR: No database name supplied, using default: $DB_NAME"
fi

if [ -z "$LDAP_SERVER" ]; then
        LDAP_SERVER=ldap://127.0.0.1:389
        echo "ERROR: No Ldap server supplied, using default: $LDAP_SERVER"
fi

if [ -z "$LDAP_BASE_DN" ]; then
        LDAP_BASE_DN=ou=People,dc=igate1,dc=com
        echo "ERROR: No Ldap base DN supplied, using default: $LDAP_BASE_DN"
fi

if [ -z "$LDAP_USER" ]; then
        LDAP_USER=cn=admin,ou=People,dc=igate1,dc=com
        echo "ERROR: No Ldap user supplied, using default: $LDAP_USER"
fi

if [ -z "$LDAP_PASSWORD" ]; then
        LDAP_PASSWORD=secret
        echo "ERROR: No Ldap password supplied, using default: $LDAP_PASSWORD"
fi

if [ -z "$LDAP_USER_DN" ]; then
        LDAP_USER_DN=ou=People,dc=igate1,dc=com
        echo "ERROR: No Ldap user DN supplied, using default: $LDAP_USER_DN"
fi

if [ -z "$CAS_LOGIN_URL" ]; then
        CAS_LOGIN_URL=http://127.0.0.1:9080/cas/login
        echo "ERROR: No CAS login url supplied, using default: $CAS_LOGIN_URL"
fi

if [ -z "$CAS_LOGOUT_URL" ]; then
        CAS_LOGOUT_URL=http://127.0.0.1:9080/cas/logout
        echo "ERROR: No CAS logout url supplied, using default: $CAS_LOGOUT_URL"
fi

if [ -z "$CAS_SERVER_URL" ]; then
        CAS_SERVER_URL=http://127.0.0.1:9080/cas
        echo "ERROR: No CAS server url supplied, using default: $CAS_SERVER_URL"
fi

if [ -z "$CAS_SERVER_NAME" ]; then
        CAS_SERVER_NAME=http://127.0.0.1:9080
        echo "ERROR: No CAS server name supplied, using default: $CAS_SERVER_NAME"
fi

if [ -z "$CAS_CLEARPASS_URL" ]; then
        CAS_CLEARPASS_URL=http://127.0.0.1:9080/cas/clearPass
        echo "WARNING: No CAS clearpass url supplied, using default: $CAS_CLEARPASS_URL"
fi

if [ -z "$LIFERAY_LOGIN_URL" ]; then
        LIFERAY_LOGIN_URL=http://127.0.0.1:8080/c/portal/login
        echo "ERROR: No Liferay login url supplied, using default: $LIFERAY_LOGIN_URL"
fi

if [ -z "$PGT_CALLBACK_URL" ]; then
        PGT_CALLBACK_URL=http://127.0.0.1:8080/CASClearPass/pgtCallback
        echo "WARNING: No PGT callback url supplied, using default: $PGT_CALLBACK_URL"
fi

if [ -z "$NUXEO_CMIS_USER" ]; then
        NUXEO_CMIS_USER=Administrator
        echo "WARNING: No Nuxeo CMIS user supplied, using default: $NUXEO_CMIS_USER"
fi

if [ -z "$NUXEO_CMIS_PASSWORD" ]; then
        NUXEO_CMIS_PASSWORD=Administrator
        echo "WARNING: No Nuxeo CMIS password supplied, using default: $NUXEO_CMIS_PASSWORD"
fi

if [ -z "$NUXEO_URL" ]; then
        NUXEO_URL=http://127.0.0.1:8090/nuxeo
        echo "WARNING: No Nuxeo server url supplied, using default: $NUXEO_URL"
fi

if [ -z "$ES2_SERVER" ]; then
        ES2_SERVER=127.0.0.1:9300
        echo "ERROR: No Elasticsearch server supplied, using default: $ES2_SERVER"
fi

if [ -z "$ES2_CLUSTER_NAME" ]; then
        ES2_CLUSTER_NAME=tenant-x-cluster2
        echo "WARNING: No Elasticsearch cluster name supplied, using default: $ES2_CLUSTER_NAME"
fi

if [ -z "$SHINDIG_URL" ]; then
        SHINDIG_URL=http://127.0.0.1:8081/shindig/
        echo "ERROR: No Shindig server supplied, using default: $SHINDIG_URL"
fi

if [ -z "$SHINDIG_SEC_TOKEN" ]; then
        SHINDIG_SEC_TOKEN=AAAAAAAAAAAA/AAAAAAAAAAAAAAAAAA/AAAAAAAAAA=
        echo "WARNING: No Shindig security token supplied, using default: $SHINDIG_SEC_TOKEN"
fi

if [ -z "$SKILL_WIKI_URL" ]; then
        SKILL_WIKI_URL=http://127.0.0.1:8080/web/guest/wiki/-/wiki/Main
        echo "WARNING: No skill wiki url supplied, using default: $SKILL_WIKI_URL"
fi

if [ -z "$LIFERAY_LINK_URL" ]; then
        LIFERAY_LINK_URL=http://127.0.0.1:8080/c
        echo "WARNING: No liferay link url supplied, using default: $LIFERAY_LINK_URL"
fi

if [ -z "$JAVA_MEM_MIN" ]; then
        JAVA_MEM_MIN=1000M
        echo "WARNING: No JVM memory minimum supplied, using default: $JAVA_MEM_MIN"
fi

if [ -z "$JAVA_MEM_MAX" ]; then
        JAVA_MEM_MAX=3000M
        echo "WARNING: No JVM memory maximum supplied, using default: $JAVA_MEM_MAX"
fi

## replace variables in template

# main configuration
echo "Configuring Liferay"
cat $LR_CONF_TEMPLATE | sed \
        -e "s/INSERT_ADMIN_MAIL_HERE/$ADMIN_MAIL/" \
        -e "s/INSERT_ADMIN_FULL_NAME_HERE/$ADMIN_FULL_NAME/" \
        -e "s/INSERT_ADMIN_FIRST_NAME_HERE/$ADMIN_FIRST_NAME/" \
        -e "s/INSERT_ADMIN_LAST_NAME_HERE/$ADMIN_LAST_NAME/" \
        -e "s/INSERT_ADMIN_PASSWORD_HERE/$ADMIN_PASSWORD/" \
        -e "s/INSERT_ADMIN_ID_HERE/$ADMIN_ID/" \
        -e "s/INSERT_COMPANY_NAME_HERE/$COMPANY_NAME/" \
        -e "s/INSERT_COMPANY_WEBID_HERE/$COMPANY_WEBID/" \
        -e "s/INSERT_COMPANY_LOCALE_HERE/$COMPANY_LOCALE/" \
        -e "s!INSERT_COMPANY_TIMEZONE_HERE!$COMPANY_TIMEZONE!" \
        -e "s/INSERT_USER_COUNTRY_HERE/$USER_COUNTRY/" \
        -e "s/INSERT_USER_LANGUAGE_HERE/$USER_LANGUAGE/" \
        -e "s/INSERT_DB_USER_HERE/$DB_USER/" \
        -e "s/INSERT_DB_PASSWORD_HERE/$DB_PASSWORD/" \
        -e "s/INSERT_DB_SERVER_HERE/$DB_SERVER/" \
        -e "s/INSERT_DB_NAME_HERE/$DB_NAME/" \
        > $LR_CONF_TMP

echo "Configuring LDAP"
cat $LDAP_CONF_TEMPLATE | sed \
        -e "s!INSERT_LDAP_SERVER_HERE!$LDAP_SERVER!" \
        -e "s/INSERT_LDAP_BASE_DN_HERE/$LDAP_BASE_DN/" \
        -e "s/INSERT_LDAP_USER_HERE/$LDAP_USER/" \
        -e "s/INSERT_LDAP_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s/INSERT_LDAP_USER_DN_HERE/$LDAP_USER_DN/" \
        > $LDAP_CONF_TMP

echo "Configuring Nuxeo CMIS connection"
cat $CMIS_CONF_TEMPLATE | sed \
        -e "s!INSERT_NUXEO_CMIS_USER_HERE!$NUXEO_CMIS_USER!" \
        -e "s/INSERT_NUXEO_CMIS_PASSWORD_HERE/$NUXEO_CMIS_PASSWORD/" \
        -e "s!INSERT_NUXEO_URL_HERE!$NUXEO_URL!" \
        > $CMIS_CONF_TMP

echo "Configuring Elasticsearch"
cat $ES_CONF_TEMPLATE | sed \
        -e "s/INSERT_ES2_SERVER_HERE/$ES2_SERVER/" \
        -e "s/INSERT_ES2_CLUSTER_NAME_HERE/$ES2_CLUSTER_NAME/" \
        > $ES_CONF_TMP

echo "Configuring Authentication Verfiers"
cp $BAS_AUTH_VER_CONF_TEMPLATE $BAS_AUTH_VER_CONF
cp $DIG_AUTH_VER_CONF_TEMPLATE $DIG_AUTH_VER_CONF
cp $POR_SESS_AUTH_VER_CONF_TEMPLATE $POR_SESS_AUTH_VER_CONF


# configure activitystreams plugin
echo "Configuring Activitystreams plugin"
mkdir -p $ACTIVITYSTREAMS_TMP_DIR
cp $ACTIVITYSTREAMS_SRC $ACTIVITYSTREAMS_TMP_DIR/$ACTIVITYSTREAMS_JAR
cd $ACTIVITYSTREAMS_TMP_DIR
# unpack
unzip $ACTIVITYSTREAMS_JAR
rm $ACTIVITYSTREAMS_JAR
# reconfigure
cat $ACTIVITYSTREAMS_PROPS | sed \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        -e "s!INSERT_LIFERAY_LINK_URL_HERE!$LIFERAY_LINK_URL!" \
        -e "s!INSERT_USER_LANGUAGE_HERE!$USER_LANGUAGE!" \
        > shindig-activitystreams.properties
# repackage and insert into Liferay
jar cmf META-INF/MANIFEST.MF $ACTIVITYSTREAMS_JAR -C . .
cp $ACTIVITYSTREAMS_JAR $ACTIVITYSTREAMS_DEST
rm -r $ACTIVITYSTREAMS_TMP_DIR


# configure CAS ClearPass SSO plugin
echo "Configuring CAS SSO plugin"
mkdir -p $CAS_CLEARPASS_TMP_DIR
cp $CAS_CLEARPASS_SRC $CAS_CLEARPASS_TMP_DIR/$CAS_CLEARPASS_JAR
cd $CAS_CLEARPASS_TMP_DIR
# unpack
unzip $CAS_CLEARPASS_JAR
rm $CAS_CLEARPASS_JAR
# reconfigure
cat $CAS_CLEARPASS_PROPS | sed \
        -e "s!INSERT_CAS_SERVER_URL_HERE!$CAS_SERVER_URL!" \
        -e "s!INSERT_CAS_CLEARPASS_URL_HERE!$CAS_CLEARPASS_URL!" \
        -e "s!INSERT_LIFERAY_LOGIN_URL_HERE!$LIFERAY_LOGIN_URL!" \
        -e "s!INSERT_PGT_CALLBACK_URL_HERE!$PGT_CALLBACK_URL!" \
        > cas_autologin.properties
cat $CAS_CLEARPASS_PORTAL_PROPS | sed \
        -e "s!INSERT_CAS_LOGOUT_URL_HERE!$CAS_LOGOUT_URL!" \
        > portal.properties
# repackage and insert into Liferay
jar cmf META-INF/MANIFEST.MF $CAS_CLEARPASS_JAR -C . .
cp $CAS_CLEARPASS_JAR $CAS_CLEARPASS_DEST
rm -r $CAS_CLEARPASS_TMP_DIR


# configure Shindig portlets
echo "Configuring Shindig portlets"
# set security token
echo $SHINDIG_SEC_TOKEN > $SHINDIG_TOKEN_FILE

mkdir -p $SHINDIG_PORTLETS_TMP_DIR
cp $SHINDIG_PORTLETS_SRC $SHINDIG_PORTLETS_TMP_DIR/$SHINDIG_PORTLETS_WAR
cd $SHINDIG_PORTLETS_TMP_DIR
# unpack
unzip $SHINDIG_PORTLETS_WAR
rm $SHINDIG_PORTLETS_WAR
# reconfigure
cat $SHINDIG_PORTLETS_PROPS | sed \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        -e "s!INSERT_SKILL_WIKI_URL_HERE!$SKILL_WIKI_URL!" \
        > WEB-INF/classes/portlet.properties
# repackage and insert into Liferay
jar cf $SHINDIG_PORTLETS_WAR -C . .
cp $SHINDIG_PORTLETS_WAR $SHINDIG_PORTLETS_DEST
rm -r $SHINDIG_PORTLETS_TMP_DIR


echo "Configuring Asset Export Tool"
mkdir -p $ASSET_EXPORT_TMP_DIR
cp $ASSET_EXPORT_SRC $ASSET_EXPORT_TMP_DIR/$ASSET_EXPORT_WAR
cd $ASSET_EXPORT_TMP_DIR
# unpack
unzip $ASSET_EXPORT_WAR
# reconfigure
cat $ASSET_EXPORT_PROPS | sed \
        -e "s!INSERT_NUXEO_URL_HERE!$NUXEO_URL!" \
        -e "s/INSERT_NUXEO_CMIS_USER_HERE/$NUXEO_CMIS_USER/" \
        -e "s/INSERT_NUXEO_CMIS_PASSWORD_HERE/$NUXEO_CMIS_PASSWORD/" \
        > WEB-INF/classes/portlet.properties
# repackage and insert into Liferay
jar cf $ASSET_EXPORT_WAR -C . .
cp $ASSET_EXPORT_WAR $ASSET_EXPORT_DEST
rm -r $ASSET_EXPORT_TMP_DIR


echo "Configuring Social Messenger"
mkdir -p $SOCIAL_MESSENGER_TMP_DIR
cp $SOCIAL_MESSENGER_SRC $SOCIAL_MESSENGER_TMP_DIR/$SOCIAL_MESSENGER_WAR
cd $SOCIAL_MESSENGER_TMP_DIR
# unpack
unzip $SOCIAL_MESSENGER_WAR
rm $SOCIAL_MESSENGER_WAR
# reconfigure
cat $SOCIAL_MESSENGER_PROPS | sed \
        -e "s!INSERT_LIFERAY_URL_HERE!$LIFERAY_URL!" \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        > WEB-INF/classes/portlet.properties
# repackage and insert into Liferay
jar cf $SOCIAL_MESSENGER_WAR -C . .
cp $SOCIAL_MESSENGER_WAR $SOCIAL_MESSENGER_DEST
rm -r $SOCIAL_MESSENGER_TMP_DIR


#echo "Configuring Corporate Search"
# TODO: configure corporate search


# tomcat configuration
echo "Configuring Tomcat Java parameters"
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
echo "Inserting Tomcat keystore and new configuration files"
cp $KEYSTORE_SRC $KEYSTORE_DEST

## replace old configuration files
cp $LR_CONF_TMP $LR_CONF
cp $LDAP_CONF_TMP $LDAP_CONF
cp $LDAP_IMPORT_CONF_TEMPLATE $LDAP_IMPORT_CONF
cp $LDAP_AUTH_CONF_TEMPLATE $LDAP_AUTH_CONF
cp $CMIS_CONF_TMP $CMIS_CONF
cp $ES_CONF_TMP $ES_CONF
cp $TOMCAT_SCRIPT_TMP $TOMCAT_SCRIPT
cp $TOMCAT_CONF_TEMPLATE $TOMCAT_CONF

# remove temporary files
echo "Removing temporary files"
rm $LR_CONF_TMP
rm $LDAP_CONF_TMP
rm $CMIS_CONF_TMP
rm $ES_CONF_TMP
rm $TOMCAT_SCRIPT_TMP

echo "End of Liferay initialization"
