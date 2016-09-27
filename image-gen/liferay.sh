#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration

LIFERAY_VERSION=7.0-ga3

# TODO: automatically set in autostart-script?
TOMCAT_VERSION=8.0.32

LIFERAY_DISTRIBUTION_SRC=http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.2%20GA3/liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip

LIFERAY_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/liferay.zip

ACTIVITYSTREAMS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/activitystreams.mod/7.0.1/activitystreams.mod-7.0.1.jar

ACTIVITYSTREAMS_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-activitystreams.jar

JSON_LIBRARY_SRC=http://central.maven.org/maven2/org/json/json/20160212/json-20160212.jar

CAS_SSO_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/casclearpassws/7.0.2-ga2/casclearpassws-7.0.2-ga2.jar

CAS_SSO_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-cas-sso.jar

SHINDIG_PORTLETS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/shindig/7.0.1/shindig-7.0.1.war

SHINDIG_PORTLETS_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-shindig-portlets.war

ASSET_EXPORT_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/AssetExportTool/7.0.1-ga2/AssetExportTool-7.0.1-ga2.war

ASSET_EXPORT_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-AssetExportTool.war

SOCIAL_MESSENGER_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/SocialMessenger/7.0.1-ga2/SocialMessenger-7.0.1-ga2.war

SOCIAL_MESSENGER_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-SocialMessenger.war

# TODO: artifact needed
#SEARCH_MASK_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/...

#SEARCH_MASK_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-search-mask.jar

LIFERAY_CONTAINER_NAME=liferay-build

LIFERAY_IMAGE_NAME=schub/liferay

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/liferay/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/liferay/*


# download Liferay
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $LIFERAY_DISTRIBUTION_FILE ]]; then
  echo "using existing Liferay distribution file $LIFERAY_DISTRIBUTION_FILE"
else
  echo "downloading Liferay $LIFERAY_VERSION distribution file"
  curl -o $LIFERAY_DISTRIBUTION_FILE -L $LIFERAY_DISTRIBUTION_SRC
fi

# download MariaDB driver
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $MARIADB_DRIVER_FILE ]]; then
  echo "using existing MariaDB driver distribution file $MARIADB_DRIVER_FILE"
else
  echo "downloading MariaDB driver distribution file"
  curl -o $MARIADB_DRIVER_FILE -L $MARIADB_DRIVER_SRC
fi

# download activitystreams plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $ACTIVITYSTREAMS_DIST_FILE ]]; then
  echo "using existing activitystreams plugin distribution file $ACTIVITYSTREAMS_DIST_FILE"
else
  echo "downloading activitystreams plugin distribution file"
  curl -o $ACTIVITYSTREAMS_DIST_FILE -L $ACTIVITYSTREAMS_DIST_SRC
fi

# download CAS ClearPass SSO plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAS_SSO_DIST_FILE ]]; then
  echo "using existing CAS ClearPass SSO plugin distribution file $CAS_SSO_DIST_FILE"
else
  echo "downloading CAS ClearPass SSO plugin distribution file"
  curl -o $CAS_SSO_DIST_FILE -L $CAS_SSO_DIST_SRC
fi

# download Shindig Porltets
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $SHINDIG_PORTLETS_DIST_FILE ]]; then
  echo "using existing Shindig Portlets distribution file $SHINDIG_PORTLETS_DIST_FILE"
else
  echo "downloading Shindig Portlets distribution file"
  curl -o $SHINDIG_PORTLETS_DIST_FILE -L $SHINDIG_PORTLETS_DIST_SRC
fi

# download Asset Export Tool
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $ASSET_EXPORT_DIST_FILE ]]; then
  echo "using existing Asset Export Tool distribution file $ASSET_EXPORT_DIST_FILE"
else
  echo "downloading Asset Export Tool distribution file"
  curl -o $ASSET_EXPORT_DIST_FILE -L $ASSET_EXPORT_DIST_SRC
fi

# download Social Messenger
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $SOCIAL_MESSENGER_DIST_FILE ]]; then
  echo "using existing Social Messenger distribution file $SOCIAL_MESSENGER_DIST_FILE"
else
  echo "downloading Social Messenger distribution file"
  curl -o $SOCIAL_MESSENGER_DIST_FILE -L $SOCIAL_MESSENGER_DIST_SRC
fi

# TODO: Corporate search


# base on schub java image
echo "Creating temporary build container $LIFERAY_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $LIFERAY_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash

# install Liferay
echo "Installing Liferay $LIFERAY_VERSION"
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME mkdir /home/liferay/
sudo docker cp $LIFERAY_DISTRIBUTION_FILE $LIFERAY_CONTAINER_NAME:/home/liferay/liferay.zip
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME sh -c "cd /home/liferay/ && unzip liferay.zip"
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME rm /home/liferay/liferay.zip
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME sh -c "cd /home/liferay/ && mv liferay-ce-portal-$LIFERAY_VERSION/* ./"
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME rm -r /home/liferay/liferay-ce-portal-$LIFERAY_VERSION/

# pre-create deployment directory
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME mkdir /home/liferay/deploy/

# third party dependencies (imagemagick and libreoffice)
echo "Installing Imagemagick and Libreoffice"
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME add-apt-repository -y ppa:libreoffice/ppa
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME apt-get update
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME apt-get install -y --force-yes imagemagick libreoffice

# plugins (still need to be configured and afterwards deployed)
# TODO: are names still important at this stage?
echo "Deploying Liferay Plugins and database driver"
sudo docker cp $ACTIVITYSTREAMS_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/activitystreams.mod-1.0.0.jar
sudo docker cp $CAS_SSO_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/casclearpassws-1.0.0.jar
sudo docker cp $SHINDIG_PORTLETS_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/shindig-7.0.1.war
sudo docker cp $ASSET_EXPORT_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/AssetExportTool-7.0.1-ga2.war
sudo docker cp $SOCIAL_MESSENGER_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/SocialMessenger-7.0.1-ga2.war
# TODO: corporate search

# inject database driver
sudo docker cp $MARIADB_DRIVER_FILE $LIFERAY_CONTAINER_NAME:/home/liferay/tomcat-$TOMCAT_VERSION/lib/ext/mariadb-java-client.jar

# inject json dependency for ActivityStreams
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME sh -c "mkdir -p /home/liferay/osgi/modules/"
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME sh -c "cd /home/liferay/osgi/modules/ && wget $JSON_LIBRARY_SRC"

# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $LIFERAY_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $LIFERAY_CONTAINER_NAME:/
done


# clean up
echo "Clearing package cache"
sudo docker exec -i -t $LIFERAY_CONTAINER_NAME apt-get clean

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $LIFERAY_CONTAINER_NAME $LIFERAY_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $LIFERAY_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $LIFERAY_CONTAINER_NAME
fi
