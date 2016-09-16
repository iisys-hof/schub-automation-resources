#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration

TOMCAT_VERSION=8.0.24

CAMUNDA_DISTRIBUTION_SRC=https://camunda.org/release/camunda-bpm/tomcat/7.4/camunda-bpm-tomcat-7.4.0.tar.gz

CAMUNDA_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/camunda.tar.gz

CAMUNDA_ACTIVITYSTREAMS_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/camunda-activitystreams/7.4.0/camunda-activitystreams-7.4.0.jar

CAMUNDA_ACTIVITYSTREAMS_DIST_FILE=$BINARY_REPO_DIRECTORY/camunda-activitystreams.jar

CAMUNDA_CAS_SSO_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/camunda-cas-sso/7.4.0/camunda-cas-sso-7.4.0.jar

CAMUNDA_CAS_SSO_DIST_FILE=$BINARY_REPO_DIRECTORY/camunda-cas-sso.jar

CAMUNDA_REST_EXTENSION_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/camunda-rest-extension/7.4.0/camunda-rest-extension-7.4.0.jar

CAMUNDA_REST_EXTENSION_DIST_FILE=$BINARY_REPO_DIRECTORY/camunda-rest-extension.jar

CAMUNDA_REST_CAS_SSO_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/camunda-rest-cas-auth/7.4.0/camunda-rest-cas-auth-7.4.0.jar

CAMUNDA_REST_CAS_SSO_DIST_FILE=$BINARY_REPO_DIRECTORY/camunda-rest-cas-sso.jar

CAS_CLIENT_DIST_SRC=http://central.maven.org/maven2/org/jasig/cas/client/cas-client-core/3.4.1/cas-client-core-3.4.1.jar

CAMUNDA_CONTAINER_NAME=camunda-build

CAMUNDA_IMAGE_NAME=schub/camunda

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/camunda/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/camunda/*

# download camunda
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAMUNDA_DISTRIBUTION_FILE ]]; then
  echo "using existing Camunda distribution file $CAMUNDA_DISTRIBUTION_FILE"
else
  echo "downloading Camunda distribution file"
  curl -o $CAMUNDA_DISTRIBUTION_FILE $CAMUNDA_DISTRIBUTION_SRC
fi

# download MariaDB driver
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $MARIADB_DRIVER_FILE ]]; then
  echo "using existing MariaDB driver distribution file $MARIADB_DRIVER_FILE"
else
  echo "downloading MariaDB driver distribution file"
  curl -o $MARIADB_DRIVER_FILE -L $MARIADB_DRIVER_SRC
fi

# download activitystreams plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAMUNDA_ACTIVITYSTREAMS_DIST_FILE ]]; then
  echo "using existing Camunda activitystreams plugin distribution file $CAMUNDA_ACTIVITYSTREAMS_DIST_FILE"
else
  echo "downloading Camunda activitystreams plugin distribution file"
  curl -o $CAMUNDA_ACTIVITYSTREAMS_DIST_FILE -L $CAMUNDA_ACTIVITYSTREAMS_DIST_SRC
fi

# download CAS SSO plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAMUNDA_CAS_SSO_DIST_FILE ]]; then
  echo "using existing Camunda CAS SSO plugin distribution file $CAMUNDA_CAS_SSO_DIST_FILE"
else
  echo "downloading Camunda CAS SSO plugin distribution file"
  curl -o $CAMUNDA_CAS_SSO_DIST_FILE -L $CAMUNDA_CAS_SSO_DIST_SRC
fi

# download Rest extension plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAMUNDA_REST_EXTENSION_DIST_FILE ]]; then
  echo "using existing Camunda Rest extension plugin distribution file $CAMUNDA_REST_EXTENSION_DIST_FILE"
else
  echo "downloading Camunda Rest extension plugin distribution file"
  curl -o $CAMUNDA_REST_EXTENSION_DIST_FILE -L $CAMUNDA_REST_EXTENSION_DIST_SRC
fi

# download Rest CAS SSO plugin
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAMUNDA_REST_CAS_SSO_DIST_FILE ]]; then
  echo "using existing Camunda Rest CAS SSO plugin distribution file $CAMUNDA_REST_CAS_SSO_DIST_FILE"
else
  echo "downloading Camunda Rest CAS SSO plugin distribution file"
  curl -o $CAMUNDA_REST_CAS_SSO_DIST_FILE -L $CAMUNDA_REST_CAS_SSO_DIST_SRC
fi


# base on schub java image
echo "Creating temporary build container $CAMUNDA_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $CAMUNDA_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash

#insert and unpack distribution
echo "Installing Camunda"
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME mkdir /home/camunda/
sudo docker cp $CAMUNDA_DISTRIBUTION_FILE $CAMUNDA_CONTAINER_NAME:/home/camunda/camunda.tar.gz
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME sh -c 'cd /home/camunda/ && tar -xzf camunda.tar.gz && rm camunda.tar.gz'

# remove examples and unused contexts
echo "Removing sample content and unused clutter"
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME rm -r /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/camunda-invoice/
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME rm -r /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/h2/
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME rm -r /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/docs/
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME rm -r /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/ROOT/
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME rm -r /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/manager/
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME rm -r /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/host-manager/

# plugins (still require configuration)
echo "Installing plugins and database driver"
sudo docker cp $CAMUNDA_ACTIVITYSTREAMS_DIST_FILE $CAMUNDA_CONTAINER_NAME:/resources/
sudo docker cp $CAMUNDA_REST_EXTENSION_DIST_FILE $CAMUNDA_CONTAINER_NAME:/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/engine-rest/WEB-INF/lib/

# SSO plugins and client library
sudo docker exec -i -t $CAMUNDA_CONTAINER_NAME sh -c "cd /home/camunda/server/apache-tomcat-$TOMCAT_VERSION/lib/ && wget $CAS_CLIENT_DIST_SRC"

sudo docker cp $CAMUNDA_CAS_SSO_DIST_FILE $CAMUNDA_CONTAINER_NAME:/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/camunda/WEB-INF/lib/
# TODO: still in debug mode
sudo docker cp $CAMUNDA_REST_CAS_SSO_DIST_FILE $CAMUNDA_CONTAINER_NAME:/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/webapps/engine-rest/WEB-INF/lib/

# inject database driver
sudo docker cp $MARIADB_DRIVER_FILE $CAMUNDA_CONTAINER_NAME:/home/camunda/server/apache-tomcat-$TOMCAT_VERSION/lib/mariadb-java-client.jar


# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $CAMUNDA_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $CAMUNDA_CONTAINER_NAME:/
done

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $CAMUNDA_CONTAINER_NAME $CAMUNDA_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $CAMUNDA_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $CAMUNDA_CONTAINER_NAME
fi