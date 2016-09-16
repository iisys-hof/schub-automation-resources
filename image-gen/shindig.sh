#!/bin/bash

#setup
echo "reading global configuration"
source ./config.sh

## basic configuration
# TODO: share tomcat image with CAS?
TOMCAT_VERSION=7.0.68

TOMCAT_DISTRIBUTION_SRC=http://apache.openmirror.de/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

TOMCAT_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/tomcat7.tar.gz

SHINDIG_DISTRIBUTION_SRC=http://central.maven.org/maven2/org/apache/shindig/shindig-server/2.5.2/shindig-server-2.5.2.war

SHINDIG_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/shindig.war

# websocket backend
WS_BACKEND_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/shindig-websocket-client/2.5.2-9/shindig-websocket-client-2.5.2-9.jar

WS_BACKEND_DIST_FILE=$BINARY_REPO_DIRECTORY/shindig-websocket-client.jar

WS_BACKEND_LIBS_DIST_SRC=$REPO_SERVER/$SOFTWARE_REPO/shindig-websocket-client-2.5.2-9-lib.tar.gz

WS_BACKEND_LIBS_DIST_FILE=$BINARY_REPO_DIRECTORY/shindig-websocket-client-lib.tar.gz

# elasticsearch plugin
ES_PLUGIN_DIST_SRC=$REPO_SERVER/$LIBRARY_REPO/de/hofuniversity/iisys/shindig-es-plugin/2.5.2-4/shindig-es-plugin-2.5.2-4.jar

ES_PLUGIN_DIST_FILE=$BINARY_REPO_DIRECTORY/shindig-es-plugin.jar

ES_PLUGIN_LIBS_DIST_SRC=$REPO_SERVER/$SOFTWARE_REPO/shindig-es-plugin-2.5.2-4-lib.tar.gz

ES_PLUGIN_LIBS_DIST_FILE=$BINARY_REPO_DIRECTORY/shindig-es-plugin-lib.tar.gz

# TODO: pre-assemble shindig with websocket backend?

SHINDIG_CONTAINER_NAME=shindig-build

SHINDIG_IMAGE_NAME=schub/shindig

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/shindig/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/shindig/*


# download Apache Tomcat 7
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $TOMCAT_DISTRIBUTION_FILE ]]; then
  echo "using existing Tomcat 7 distribution file $TOMCAT_DISTRIBUTION_FILE"
else
  echo "downloading Tomcat 7 distribution file"
  curl -o $TOMCAT_DISTRIBUTION_FILE $TOMCAT_DISTRIBUTION_SRC
fi

# download Apache Shindig
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $SHINDIG_DISTRIBUTION_FILE ]]; then
  echo "using existing Shindig distribution file $SHINDIG_DISTRIBUTION_FILE"
else
  echo "downloading Shindig distribution file"
  curl -o $SHINDIG_DISTRIBUTION_FILE $SHINDIG_DISTRIBUTION_SRC
fi

# download Websocket Backend and libraries
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $WS_BACKEND_DIST_FILE ]]; then
  echo "using existing Websocket Backend distribution file $WS_BACKEND_DIST_FILE"
else
  echo "downloading Websocket Backend distribution file"
  curl -o $WS_BACKEND_DIST_FILE $WS_BACKEND_DIST_SRC
fi
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $WS_BACKEND_LIBS_DIST_FILE ]]; then
  echo "using existing Websocket Backend libraries distribution file $WS_BACKEND_LIBS_DIST_FILE"
else
  echo "downloading Websocket Backend libraries distribution file"
  curl -o $WS_BACKEND_LIBS_DIST_FILE $WS_BACKEND_LIBS_DIST_SRC
fi

# download Elasticsearch plugin and libraries
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $ES_PLUGIN_DIST_FILE ]]; then
  echo "using existing Elasticsearch plugin distribution file $ES_PLUGIN_DIST_FILE"
else
  echo "downloading Elasticsearch plugin distribution file"
  curl -o $ES_PLUGIN_DIST_FILE $ES_PLUGIN_DIST_SRC
fi
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $ES_PLUGIN_LIBS_DIST_FILE ]]; then
  echo "using existing Elasticsearch plugin libraries distribution file $ES_PLUGIN_LIBS_DIST_FILE"
else
  echo "downloading Elasticsearch plugin libraries distribution file"
  curl -o $ES_PLUGIN_LIBS_DIST_FILE $ES_PLUGIN_LIBS_DIST_SRC
fi


# base on schub java image
echo "Creating temporary build container $SHINDIG_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $SHINDIG_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash

# install tomcat
echo "Installing Tomcat 7, removing clutter and its websocket library"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME mkdir /home/shindig/
sudo docker cp $TOMCAT_DISTRIBUTION_FILE $SHINDIG_CONTAINER_NAME:/home/shindig/tomcat7.tar.gz
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME sh -c "cd /home/shindig/ && tar -xzf tomcat7.tar.gz"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME rm /home/shindig/tomcat7.tar.gz
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME sh -c "cd /home/shindig/ && mv apache-tomcat-$TOMCAT_VERSION/* ./"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME rm -r /home/shindig/apache-tomcat-$TOMCAT_VERSION/
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME sh -c "rm -r /home/shindig/webapps/*"

# remove tomcat's websocket library conflicting with tyrus
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME rm /home/shindig/lib/tomcat7-websocket.jar

# install Shindig into tomcat
echo "Deploying Shindig into Tomcat"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME mkdir /home/shindig/webapps/shindig/
sudo docker cp $SHINDIG_DISTRIBUTION_FILE $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/shindig.war
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME sh -c "cd /home/shindig/webapps/shindig/ && unzip shindig.war"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME rm /home/shindig/webapps/shindig/shindig.war

# context for profile pictures
echo "Creating Profile Picture Context"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME mkdir /home/shindig/webapps/pictures/

# SCHub custom configuration and binaries
echo "Reconfiguring Shindig"
# insert general shindig plugin, token and CORS configuration
sudo docker cp $TEMPLATE_REPO_DIRECTORY/shindig/web.xml $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/WEB-INF/web.xml
sudo docker cp $TEMPLATE_REPO_DIRECTORY/shindig/container.js $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/WEB-INF/classes/containers/default/container.js

# websocket backend
echo "Installing Websocket Backend"
sudo docker cp $WS_BACKEND_DIST_FILE $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/WEB-INF/lib/
sudo docker cp $WS_BACKEND_LIBS_DIST_FILE $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/WEB-INF/lib/shindig-websocket-client-lib.tar.gz
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME sh -c "cd /home/shindig/webapps/shindig/WEB-INF/lib/ && tar -xzf shindig-websocket-client-lib.tar.gz"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME rm /home/shindig/webapps/shindig/WEB-INF/lib/shindig-websocket-client-lib.tar.gz

# elasticsearch plugin
echo "Installing Elasticsearch Plugin"
sudo docker cp $ES_PLUGIN_DIST_FILE $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/WEB-INF/lib/
sudo docker cp $ES_PLUGIN_LIBS_DIST_FILE $SHINDIG_CONTAINER_NAME:/home/shindig/webapps/shindig/WEB-INF/lib/shindig-es-plugin-lib.tar.gz
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME sh -c "cd /home/shindig/webapps/shindig/WEB-INF/lib/ && tar -xzf shindig-es-plugin-lib.tar.gz"
sudo docker exec -i -t $SHINDIG_CONTAINER_NAME rm /home/shindig/webapps/shindig/WEB-INF/lib/shindig-es-plugin-lib.tar.gz


# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $SHINDIG_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $SHINDIG_CONTAINER_NAME:/
done

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $SHINDIG_CONTAINER_NAME $SHINDIG_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $SHINDIG_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $SHINDIG_CONTAINER_NAME
fi