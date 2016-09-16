#!/bin/bash

## constants
# seconds to wait after starting before manipulating server
STARTUP_WAIT=30

MAIL_CONF="/opt/open-xchange/etc/mail.properties"
MAIL_CONF_TEMPLATE="/templates/mail.properties"
MAIL_CONF_TMP="/tmp/mail.properties"

LDAP_CONF="/opt/oxldapsync/etc/ldapsync.conf"
LDAP_CONF_TEMPLATE="/templates/ldapsync.conf"
LDAP_CONF_TMP="/tmp/ldapsync.conf"

LDAP_AUTH_CONF="/opt/open-xchange/etc/ldapauth.properties"
LDAP_AUTH_CONF_TEMPLATE="/templates/ldapauth.properties"
LDAP_AUTH_CONF_TMP="/tmp/ldapauth.properties"

LOGIN_CONF="/opt/open-xchange/etc/login.properties"
LOGIN_CONF_TMP="/tmp/login.properties"

SESSIOND_CONF="/opt/open-xchange/etc/sessiond.properties"
SESSIOND_CONF_TMP="/tmp/sessiond.properties"

LDAP_MAPPING="/opt/oxldapsync/etc/mapping.openldap.conf"
LDAP_MAPPING_TMP="/tmp/mapping.openldap.conf"

MEM_CONF_SCRIPT="/opt/open-xchange/etc/ox-scriptconf.sh"
MEM_CONF_SCRIPT_TEMPLATE="/templates/ox-scriptconf.sh"
MEM_CONF_SCRIPT_TMP="/tmp/ox-scriptconf.sh"

ACTIVITYSTREAMS_CONF_ETC="/opt/open-xchange/etc/activitystreams.properties"
ACTIVITYSTREAMS_CONF_BUN="/opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams/conf/activitystreams.properties"
ACTIVITYSTREAMS_CONF_TEMPLATE="/templates/activitystreams.properties"
ACTIVITYSTREAMS_CONF_TMP="/tmp/activitystreams.properties"

CAS_SSO_CONF_ETC="/opt/open-xchange/etc/cas-sso.properties"
CAS_SSO_CONF_BUN="/opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso/conf/cas-sso.properties"
CAS_SSO_CONF_TEMPLATE="/templates/cas-sso.properties"
CAS_SSO_CONF_TMP="/tmp/cas-sso.properties"

SSL_CONFIG_SRC="/templates/default-ssl.conf"
SSL_CONFIG_DEST="/etc/apache2/sites-enabled/default-ssl.conf"
SSL_SRC_DIR="/ssl"
SSL_DEST_DIR="/etc/apache2/ssl"
CERT_FILE="$SSL_DEST_DIR/server.crt"
KEY_FILE="$SSL_DEST_DIR/server.key.insecure"

## read environment variables
# check and set default values

# main configuration
if [ -z "$DB_NAME" ]; then
        DB_NAME=open_xchange_tenant
        echo "ERROR: No database name supplied, using default: $DB_NAME"
fi

if [ -z "$DATA_DB_NAME" ]; then
        DATA_DB_NAME=open_xchange_tenant_data
        echo "ERROR: No data database name supplied, using default: $DATA_DB_NAME"
fi

if [ -z "$DB_USER" ]; then
        DB_USER=open_xchange_tenant
        echo "ERROR: No database user supplied, using default: $DB_USER"
fi

if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD=nuxeo-tenant-pw
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
        LDAP_USER_BASE=ou=people,dc=tenant,dc=org
        echo "ERROR: No Ldap user base supplied, using default: $LDAP_USER_BASE"
fi

if [ -z "$LDAP_GROUP_BASE" ]; then
        LDAP_GROUP_BASE=ou=groups,dc=tenant,dc=org
        echo "ERROR: No Ldap group base supplied, using default: $LDAP_GROUP_BASE"
fi

if [ -z "$SERVER_NAME" ]; then
        SERVER_NAME=tenant-ox
        echo "WARNING: No server name supplied, using default: $SERVER_NAME"
fi

if [ -z "$MASTER_PASSWORD" ]; then
        MASTER_PASSWORD=tenant-ox-master-pw
        echo "ERROR: No master password supplied, using default: $MASTER_PASSWORD"
fi

if [ -z "$ADMIN_PASSWORD" ]; then
        ADMIN_PASSWORD=ox-admin-pw
        echo "ERROR: No admin password supplied, using default: $ADMIN_PASSWORD"
fi

if [ -z "$ADMIN_MAIL" ]; then
        ADMIN_MAIL=admin@tenant.schub.de
        echo "WARNING: No admin mail address supplied, using default: $ADMIN_MAIL"
fi

if [ -z "$MAIL_MASTER_PASSWORD" ]; then
        MAIL_MASTER_PASSWORD=dovecot-master-pw
        echo "WARNING: No mailserver master password supplied, using default: $MAIL_MASTER_PASSWORD"
fi

if [ -z "$IMAP_SERVER" ]; then
        IMAP_SERVER=imap://127.0.0.1:143
        echo "ERROR: No imap server supplied, using default: $IMAP_SERVER"
fi

if [ -z "$SMTP_SERVER" ]; then
        SMTP_SERVER=smtp://127.0.0.1:25
        echo "ERROR: No smtp server supplied, using default: $SMTP_SERVER"
fi

if [ -z "$JAVA_MEM_MIN" ]; then
        JAVA_MEM_MIN=1000M
        echo "WARNING: No JVM memory minimum supplied, using default: $JAVA_MEM_MIN"
fi

if [ -z "$JAVA_MEM_MAX" ]; then
        JAVA_MEM_MAX=2000M
        echo "WARNING: No JVM memory maximum supplied, using default: $JAVA_MEM_MAX"
fi

# plugins

if [ -z "$APPSUITE_URL" ]; then
        APPSUITE_URL=http://127.0.0.1/appsuite/
        echo "WARNING: No appsuite url supplied, using default: $APPSUITE_URL"
fi

if [ -z "$SHINDIG_URL" ]; then
        SHINDIG_URL=http://127.0.0.1:8080/shindig/
        echo "WARNING: No shindig url supplied, using default: $SHINDIG_URL"
fi

if [ -z "$CAS_URL" ]; then
        CAS_URL=http://127.0.0.1:8080/cas/
        echo "WARNING: No CAS url supplied, using default: $CAS_URL"
fi

if [ -z "$CAS_CLEARPASS_URL" ]; then
        CAS_CLEARPASS_URL=http://127.0.0.1:8080/cas/clearPass
        echo "WARNING: No CAS clearpass url supplied, using default: $CAS_CLEARPASS_URL"
fi

if [ -z "$OX_CAS_AUTH_URL" ]; then
        OX_CAS_AUTH_URL=http://127.0.0.1/appsuite/api/casauth
        echo "WARNING: No CAS authentication url supplied, using default: $OX_CAS_AUTH_URL"
fi

if [ -z "$CLEARPASS_CALLBACK" ]; then
        CLEARPASS_CALLBACK=http://127.0.0.1/appsuite/api/cascallback
        echo "WARNING: No CAS clearpass callback url supplied, using default: $CLEARPASS_CALLBACK"
fi


## replace variables in template

# main configuration
echo "Configuring mail server"
cat $MAIL_CONF_TEMPLATE | sed \
        -e "s/INSERT_MAIL_MASTER_PASSWORD_HERE/$MAIL_MASTER_PASSWORD/" \
        -e "s!INSERT_IMAP_SERVER_HERE!$IMAP_SERVER!" \
        -e "s!INSERT_SMTP_SERVER_HERE!$SMTP_SERVER!" \
        > $MAIL_CONF_TMP

# ldap data import
echo "Configuring LDAP import"
cat $LDAP_CONF_TEMPLATE | sed \
        -e "s!INSERT_LDAP_SERVER_HERE!$LDAP_SERVER!" \
        -e "s/INSERT_LDAP_USER_HERE/$LDAP_USER/" \
        -e "s/INSERT_LDAP_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s/INSERT_LDAP_USER_BASE_HERE/$LDAP_USER_BASE/" \
        -e "s/INSERT_LDAP_GROUP_BASE_HERE/$LDAP_GROUP_BASE/" \
        > $LDAP_CONF_TMP

# ldap authentication
echo "Configuring LDAP authentication"
cat $LDAP_AUTH_CONF_TEMPLATE | sed \
        -e "s!INSERT_LDAP_SERVER_HERE!$LDAP_SERVER!" \
        -e "s/INSERT_LDAP_USER_HERE/$LDAP_USER/" \
        -e "s/INSERT_LDAP_PASSWORD_HERE/$LDAP_PASSWORD/" \
        -e "s/INSERT_LDAP_USER_BASE_HERE/$LDAP_USER_BASE/" \
        > $LDAP_AUTH_CONF_TMP

# autologin
echo "Configuring Autologin"
cat $LOGIN_CONF | sed \
        -e "s/autologin=false/autologin=true/" \
        > $LOGIN_CONF_TMP

cat $SESSIOND_CONF | sed \
        -e "s/autologin=false/autologin=true/" \
        > $SESSIOND_CONF_TMP

# fix ldap mapping for newer OX versions
echo "Fixing LDAP mapping"
cat $LDAP_MAPPING | sed \
        -e "s/access-forum/#access-forum/" \
        -e "s/access-pinboard-write/#access-pinboard-write/" \
        -e "s/access-projects/#access-projects/" \
        -e "s/access-rss-bookmarks/#access-rss-bookmarks/" \
        -e "s/access-rss-portal/#access-rss-portal/" \
        > $LDAP_MAPPING_TMP

# java memory configuration
echo "Setting Java parameters"
cat $MEM_CONF_SCRIPT_TEMPLATE | sed \
        -e "s/INSERT_JAVA_MEM_MIN_HERE/$JAVA_MEM_MIN/" \
        -e "s/INSERT_JAVA_MEM_MAX_HERE/$JAVA_MEM_MAX/" \
        > $MEM_CONF_SCRIPT_TMP

# activitystreams plugin
echo "Configuring activitystreams plugin"
cat $ACTIVITYSTREAMS_CONF_TEMPLATE | sed \
        -e "s!INSERT_APPSUITE_URL_HERE!$APPSUITE_URL!" \
        -e "s!INSERT_SHINDIG_URL_HERE!$SHINDIG_URL!" \
        > $ACTIVITYSTREAMS_CONF_TMP


# CAS SSO plugin
echo "Configuring CAS SSO plugin"
cat $CAS_SSO_CONF_TEMPLATE | sed \
        -e "s!INSERT_CAS_URL_HERE!$CAS_URL!" \
        -e "s!INSERT_CAS_CLEARPASS_URL_HERE!$CAS_CLEARPASS_URL!" \
        -e "s!INSERT_OX_CAS_AUTH_URL_HERE!$OX_CAS_AUTH_URL!" \
        -e "s!INSERT_CLEARPASS_CALLBACK_URL_HERE!$CLEARPASS_CALLBACK!" \
        > $CAS_SSO_CONF_TMP


# TODO: CMIS plugin


# handle SSL files
echo "Inserting SSL Key and Certificate"
mkdir -p $SSL_DEST_DIR
cp $SSL_SRC_DIR/*.crt $CERT_FILE
cp $SSL_SRC_DIR/*.key $KEY_FILE

cp $SSL_CONFIG_SRC $SSL_CONFIG_DEST


## replace old configuration files
echo "Inserting new configuration files"
cp $LDAP_CONF_TMP $LDAP_CONF
cp $ACTIVITYSTREAMS_CONF_TMP $ACTIVITYSTREAMS_CONF_ETC
cp $ACTIVITYSTREAMS_CONF_TMP $ACTIVITYSTREAMS_CONF_BUN
cp $CAS_SSO_CONF_TMP $CAS_SSO_CONF_ETC
cp $CAS_SSO_CONF_TMP $CAS_SSO_CONF_BUN

# remove temporary files
echo "Removing temporary files"
rm $LDAP_CONF_TMP
rm $ACTIVITYSTREAMS_CONF_TMP
rm $CAS_SSO_CONF_TMP

## determine if database has already been initialized
TABLE_COUNT="$(mysql -u $DB_USER -h $DB_HOST -P $DB_PORT -p$DB_PASSWORD -e "SELECT COUNT(DISTINCT 'table_name') FROM information_schema.columns WHERE table_schema = '$DB_NAME';" | tail -1)"
if [[ "$TABLE_COUNT" == "0" ]]; then
    echo "Configuration database empty"
    DB_INITIALIZED=false
else
    echo "Configuration database not empty - not initializing"
    DB_INITIALIZED=true
fi

## execute setup routines
# initialize database
# TODO: -i automatically deletes the database? what if it already exists but is empty?
if [[ "$DB_INITIALIZED" != "true" ]]; then
    echo "Initializing configuration database"
    /opt/open-xchange/sbin/initconfigdb -i --configdb-user=$DB_USER --configdb-pass=$DB_PASSWORD --configdb-host=$DB_HOST --configdb-port=$DB_PORT --configdb-dbname=$DB_NAME
else
    echo "Not initializing configuration database"
fi

# installation
echo "Executing Open-Xchange installer"
/opt/open-xchange/sbin/oxinstaller --servername=$SERVER_NAME --no-license --configdb-pass=$DB_PASSWORD --master-pass=$MASTER_PASSWORD --network-listener-host=* --servermemory 1024 --configdb-user=$DB_USER --configdb-dbname=$DB_NAME --configdb-readhost=$DB_HOST --configdb-writehost=$DB_HOST

# set mail and ldap authentication config
echo "Inserting new post-installation configuration files"
cp $MAIL_CONF_TMP $MAIL_CONF
cp $LDAP_AUTH_CONF_TMP $LDAP_AUTH_CONF
cp $LOGIN_CONF_TMP $LOGIN_CONF
cp $SESSIOND_CONF_TMP $SESSIOND_CONF
cp $LDAP_MAPPING_TMP $LDAP_MAPPING
cp $MEM_CONF_SCRIPT_TMP $MEM_CONF_SCRIPT

echo "Removing temporary files"
rm $MAIL_CONF_TMP
rm $LDAP_AUTH_CONF_TMP
rm $LOGIN_CONF_TMP
rm $LDAP_MAPPING_TMP
rm $MEM_CONF_SCRIPT_TMP


# register server (service needs to be started)
/etc/init.d/open-xchange start
# TODO: more elegant way - checking if it has started
echo "waiting $STARTUP_WAIT seconds for startup"
sleep $STARTUP_WAIT
if [[ "$DB_INITIALIZED" != "true" ]]; then
    echo "Registering server"
    /opt/open-xchange/sbin/registerserver -n $SERVER_NAME -A oxadminmaster -P $MASTER_PASSWORD
else
    echo "Not registering server"
fi

# register filestore
if [[ "$DB_INITIALIZED" != "true" ]]; then
    echo "Registering filestore"
    /opt/open-xchange/sbin/registerfilestore -A oxadminmaster -P $MASTER_PASSWORD -t file:/var/opt/filestore -s 1000000
else
    echo "Not registering filestore"
fi

# register database
if [[ "$DB_INITIALIZED" != "true" ]]; then
    echo "Registering data database"
    /opt/open-xchange/sbin/registerdatabase -A oxadminmaster -P $MASTER_PASSWORD -n $DATA_DB_NAME -p $DB_PASSWORD -m true -u $DB_USER -H $DB_HOST
else
    echo "Not registering data database"
fi

## create context for users
# create context and context admin
if [[ "$DB_INITIALIZED" != "true" ]]; then
    echo "Creating context"
    /opt/open-xchange/sbin/createcontext -A oxadminmaster -P $MASTER_PASSWORD -c 1 -u oxadmin -d "Context Admin" -g Admin -s User -p $ADMIN_PASSWORD -L defaultcontext -e $ADMIN_MAIL -q 1024 --access-combination-name=groupware_standard
else
    echo "Not creating context"
fi

# LDAP Import
# fix umlauts first
echo "Fixing locale"
locale-gen de_DE.UTF-8
export LANG=de_DE.UTF-8
echo "Importing users from LDAP"
/opt/oxldapsync/sbin/oxldapsync.pl -f $LDAP_CONF -A oxadmin -P $ADMIN_PASSWORD -c 1 -v -s

# disable initialization routine
echo "Disabling initialization script"
cp /entrypoint.sh /entrypoint-init.sh
cp /entrypoint-noinit.sh /entrypoint.sh

echo "End of Open-Xchange initialization"
