#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration

NUXEO_VERSION=7.10

NUXEO_CAS_PLUGIN_DISTRIBUTION_SOURCE=https://maven-eu.nuxeo.org/nexus/content/repositories/public-releases/org/nuxeo/ecm/platform/nuxeo-platform-login-cas2/$NUXEO_VERSION/nuxeo-platform-login-cas2-$NUXEO_VERSION.jar

ACTIVITYSTREAMS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/nuxeo/nuxeo-activitystreams/7.10/nuxeo-activitystreams-7.10.jar

ACTIVITYSTREAMS_DIST_FILE=$BINARY_REPO_DIRECTORY/nuxeo-activitystreams.jar

CAMUNDA_OPS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/nuxeo/nuxeo-camunda-operations/7.10/nuxeo-camunda-operations-7.10.jar

CAMUNDA_OPS_DIST_FILE=$BINARY_REPO_DIRECTORY/nuxeo-camunda-operations.jar

NUXEO_CONTAINER_NAME=nuxeo-build

NUXEO_IMAGE_NAME=schub/nuxeo

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/nuxeo/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/nuxeo/*


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

# download Camunda operations plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAMUNDA_OPS_DIST_FILE ]]; then
  echo "using existing Camunda operations plugin distribution file $CAMUNDA_OPS_DIST_FILE"
else
  echo "downloading Camunda operations plugin distribution file"
  curl -o $CAMUNDA_OPS_DIST_FILE -L $CAMUNDA_OPS_DIST_SRC
fi


# base on schub java image
echo "Creating temporary build container $NUXEO_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $NUXEO_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash


# install Nuxeo
echo "Installing Nuxeo $NUXEO_VERSION and dependencies"
sudo docker exec -i -t $NUXEO_CONTAINER_NAME mkdir /home/nuxeo/

# install from packages, including third party dependencies
sudo docker exec -i -t $NUXEO_CONTAINER_NAME sh -c "wget -qO - http://apt.nuxeo.org/nuxeo.key | sudo apt-key add -"
sudo docker exec -i -t $NUXEO_CONTAINER_NAME apt-add-repository "deb http://apt.nuxeo.org trusty releases" 
sudo docker exec -i -t $NUXEO_CONTAINER_NAME apt-get update
sudo docker exec -i -t $NUXEO_CONTAINER_NAME apt-get install -y nuxeo=$NUXEO_VERSION-01
sudo docker exec -i -t $NUXEO_CONTAINER_NAME chown -R nuxeo:nuxeo /home/nuxeo/

# install CAS plugin
echo "Installing Plugins and database driver"
sudo docker exec -i -t $NUXEO_CONTAINER_NAME sh -c "cd /var/lib/nuxeo/server/nxserver/bundles/ && wget $NUXEO_CAS_PLUGIN_DISTRIBUTION_SOURCE"

# plugins (still need to be configured and injected)
sudo docker cp $ACTIVITYSTREAMS_DIST_FILE $NUXEO_CONTAINER_NAME:/resources/
sudo docker cp $CAMUNDA_OPS_DIST_FILE $NUXEO_CONTAINER_NAME:/resources/

# plugins that don't need to be configured
sudo docker exec -i -t $NUXEO_CONTAINER_NAME mkdir /var/lib/nuxeo/server/nxserver/plugins/
sudo docker exec -i -t $NUXEO_CONTAINER_NAME chown -R nuxeo:nuxeo /var/lib/nuxeo/server/nxserver/plugins/


# inject database driver
sudo docker cp $MARIADB_DRIVER_FILE $NUXEO_CONTAINER_NAME:/var/lib/nuxeo/server/lib/mariadb-java-client.jar
sudo docker cp $MARIADB_DRIVER_FILE $NUXEO_CONTAINER_NAME:/var/lib/nuxeo/server/nxserver/lib/mariadb-java-client.jar

# configuration directory
sudo docker exec -i -t $NUXEO_CONTAINER_NAME mkdir /var/lib/nuxeo/server/nxserver/config/
sudo docker exec -i -t $NUXEO_CONTAINER_NAME chown -R nuxeo:nuxeo /var/lib/nuxeo/server/nxserver/config/

# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $NUXEO_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $NUXEO_CONTAINER_NAME:/
done


# cleanup
echo "Clearing package cache"
sudo docker exec -i -t $NUXEO_CONTAINER_NAME apt-get clean

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $NUXEO_CONTAINER_NAME $NUXEO_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $NUXEO_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $NUXEO_CONTAINER_NAME
fi