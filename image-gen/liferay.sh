#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration

LIFERAY_VERSION=7.0-ga2

# TODO: automatically set in autostart-script?
TOMCAT_VERSION=8.0.32

LIFERAY_DISTRIBUTION_SRC=http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.1%20GA2/liferay-ce-portal-tomcat-7.0-ga2-20160610113014153.zip

LIFERAY_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/liferay.zip

ACTIVITYSTREAMS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/activitystreams/7.0.0-ga1/activitystreams-7.0.0-b8.jar

ACTIVITYSTREAMS_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-activitystreams.jar

# not compatible anymore
#CAS_SSO_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/CASClearPass/7.0.0-b8/CASClearPass-7.0.0-ga1.war

#CAS_SSO_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-cas-sso.war

SHINDIG_PORTLETS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/liferay/shindig/7.0.0-b8/shindig-7.0.0-b8.war

SHINDIG_PORTLETS_DIST_FILE=$BINARY_REPO_DIRECTORY/liferay-shindig-portlets.war

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
#if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAS_SSO_DIST_FILE ]]; then
#  echo "using existing CAS ClearPass SSO plugin distribution file $CAS_SSO_DIST_FILE"
#else
#  echo "downloading CAS ClearPass SSO plugin distribution file"
#  curl -o $CAS_SSO_DIST_FILE -L $CAS_SSO_DIST_SRC
#fi

# download Shindig Porltets
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $SHINDIG_PORTLETS_DIST_FILE ]]; then
  echo "using existing Shindig Portlets distribution file $SHINDIG_PORTLETS_DIST_FILE"
else
  echo "downloading Shindig Portlets distribution file"
  curl -o $SHINDIG_PORTLETS_DIST_FILE -L $SHINDIG_PORTLETS_DIST_SRC
fi


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
#sudo docker cp $CAS_SSO_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/CASClearPass-7.0.0-b6.war
sudo docker cp $SHINDIG_PORTLETS_DIST_FILE $LIFERAY_CONTAINER_NAME:/resources/shindig-7.0.0-b6.war

# TODO: christian's plugins


# TODO: makeshift plugins? (bpmn upload, elasticsearch dummy)


# inject database driver
sudo docker cp $MARIADB_DRIVER_FILE $LIFERAY_CONTAINER_NAME:/home/liferay/tomcat-$TOMCAT_VERSION/lib/ext/mariadb-java-client.jar


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