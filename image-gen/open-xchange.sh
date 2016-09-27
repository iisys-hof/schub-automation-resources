#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration

OX_ACTIVITYSTREAMS_DIST_SRC=$REPO_SERVER/$SOFTWARE_REPO/open-xchange-activitystreams-7.8.0.tar.gz

OX_ACTIVITYSTREAMS_DIST_FILE=$BINARY_REPO_DIRECTORY/open-xchange-activitystreams.tar.gz

OX_CAS_SSO_DIST_SRC=$REPO_SERVER/$SOFTWARE_REPO/open-xchange-cas-sso-7.8.1.tar.gz

OX_CAS_SSO_DIST_FILE=$BINARY_REPO_DIRECTORY/open-xchange-cas-sso.tar.gz

OX_CONTAINER_NAME=open-xchange-build

OX_IMAGE_NAME=schub/open-xchange

OX_FILESTORE_DIRECTORY=/var/opt/filestore

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/open-xchange/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/open-xchange/*


# download Open-Xchange activitystreams bundle
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $OX_ACTIVITYSTREAMS_DIST_FILE ]]; then
  echo "using existing Open-Xchange activitystreams bundle file $OX_ACTIVITYSTREAMS_DIST_FILE"
else
  echo "downloading Open-Xchange activitystreams bundle distribution file"
  curl -o $OX_ACTIVITYSTREAMS_DIST_FILE $OX_ACTIVITYSTREAMS_DIST_SRC
fi

# download Open-Xchange CAS SSO bundle
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $OX_CAS_SSO_DIST_FILE ]]; then
  echo "using existing Open-Xchange CAS SSO bundle file $OX_CAS_SSO_DIST_FILE"
else
  echo "downloading Open-Xchange CAS SSO bundle distribution file"
  curl -o $OX_CAS_SSO_DIST_FILE $OX_CAS_SSO_DIST_SRC
fi

# base on schub java image
echo "Creating temporary build container $OX_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $OX_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash

# install Open-Xchange from packages
echo "Installing Open-Xchange"
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "echo \"deb http://software.open-xchange.com/products/appsuite/stable/appsuiteui/DebianWheezy/ /\" > /etc/apt/sources.list.d/open-xchange.list"
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "echo \"deb http://software.open-xchange.com/products/appsuite/stable/backend/DebianWheezy/ /\" >> /etc/apt/sources.list.d/open-xchange.list"
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "echo \"deb http://software.open-xchange.com/components/unsupported/oxldapsync/DebianWheezy/ /\" >> /etc/apt/sources.list.d/open-xchange.list"
sudo docker exec -i -t $OX_CONTAINER_NAME apt-get update
# note: explicit package versions are useless since old versions are not kept on the server
sudo docker exec -i -t $OX_CONTAINER_NAME apt-get install -y --force-yes \
  open-xchange \
  open-xchange-grizzly \
  open-xchange-admin \
  open-xchange-appsuite \
  open-xchange-appsuite-backend \
  open-xchange-appsuite-manifest \
  open-xchange-authentication-ldap \
  open-xchange-l10n-de-de \
  open-xchange-appsuite-l10n-de-de \
  oxldapsync

# create additional folders
sudo docker exec -i -t $OX_CONTAINER_NAME mkdir /home/open-xchange/
sudo docker exec -i -t $OX_CONTAINER_NAME mkdir $OX_FILESTORE_DIRECTORY
sudo docker exec -i -t $OX_CONTAINER_NAME chown -R open-xchange:open-xchange /home/open-xchange/
sudo docker exec -i -t $OX_CONTAINER_NAME chown -R open-xchange:open-xchange $OX_FILESTORE_DIRECTORY

# setup apache
echo "Reconfiguring Apache Httpd Server"
sudo docker exec -i -t $OX_CONTAINER_NAME a2enmod proxy proxy_http proxy_balancer expires deflate headers rewrite mime setenvif ssl

# include apache configuration suitable for Ubuntu 14.04
sudo docker cp $TEMPLATE_REPO_DIRECTORY/open-xchange/proxy_http.conf $OX_CONTAINER_NAME:/etc/apache2/conf-enabled/proxy_http.conf
sudo docker cp $TEMPLATE_REPO_DIRECTORY/open-xchange/000-default.conf $OX_CONTAINER_NAME:/etc/apache2/sites-enabled/000-default.conf

# plugins
echo "Installing plugins"
sudo docker exec -i -t $OX_CONTAINER_NAME mkdir -p /opt/open-xchange/osgi/bundle.d/
sudo docker exec -i -t $OX_CONTAINER_NAME chown -R open-xchange:open-xchange /opt/open-xchange/osgi/bundle.d/

sudo docker exec -i -t $OX_CONTAINER_NAME mkdir /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams/
sudo docker exec -i -t $OX_CONTAINER_NAME chown -R open-xchange:open-xchange /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams/
sudo docker cp $OX_ACTIVITYSTREAMS_DIST_FILE $OX_CONTAINER_NAME:/opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams/open-xchange-activitystreams.tar.gz
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "cd /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams/ && tar -xzf open-xchange-activitystreams.tar.gz"
sudo docker exec -i -t $OX_CONTAINER_NAME rm /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams/open-xchange-activitystreams.tar.gz
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "echo '/opt/open-xchange/bundles/de.hofuniversity.iisys.ox.activitystreams@start' > /opt/open-xchange/osgi/bundle.d/de.hofuniversity.iisys.ox.activitystreams.ini"

sudo docker exec -i -t $OX_CONTAINER_NAME mkdir /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso/
sudo docker exec -i -t $OX_CONTAINER_NAME chown -R open-xchange:open-xchange /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso/
sudo docker cp $OX_CAS_SSO_DIST_FILE $OX_CONTAINER_NAME:/opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso/open-xchange-cas-sso.tar.gz
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "cd /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso/ && tar -xzf open-xchange-cas-sso.tar.gz"
sudo docker exec -i -t $OX_CONTAINER_NAME rm /opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso/open-xchange-cas-sso.tar.gz
sudo docker exec -i -t $OX_CONTAINER_NAME sh -c "echo '/opt/open-xchange/bundles/de.hofuniversity.iisys.ox.sso@start' > /opt/open-xchange/osgi/bundle.d/de.hofuniversity.iisys.ox.sso.ini"

# TODO: CMIS plugin


# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $OX_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $OX_CONTAINER_NAME:/
done

# clean up
echo "Clearing package cache"
sudo docker exec -i -t $OX_CONTAINER_NAME apt-get clean

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $OX_CONTAINER_NAME $OX_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $OX_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $OX_CONTAINER_NAME
fi