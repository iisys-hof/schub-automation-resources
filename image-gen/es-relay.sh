#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration
# TODO: share tomcat image with CAS and Shindig?
TOMCAT_VERSION=7.0.72

TOMCAT_DISTRIBUTION_SRC=http://apache.mirror.digionline.de/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

TOMCAT_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/tomcat7.tar.gz

RELAY_DISTRIBUTION_SRC=$REPO_SERVER/$SOFTWARE_REPO/de/hofuniversity/iisys/schub-elasticsearch-relay/0.5.9/schub-elasticsearch-relay-0.5.9.war

RELAY_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/es-relay.war

RELAY_CONTAINER_NAME=es-relay-build

RELAY_IMAGE_NAME=schub/es-relay

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/es-relay/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/es-relay/*


# download Apache Tomcat 7
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $TOMCAT_DISTRIBUTION_FILE ]]; then
  echo "using existing Tomcat 7 distribution file $TOMCAT_DISTRIBUTION_FILE"
else
  echo "downloading Tomcat 7 distribution file"
  curl -o $TOMCAT_DISTRIBUTION_FILE $TOMCAT_DISTRIBUTION_SRC
fi

# download Elasticsearch Wrapper
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $RELAY_DISTRIBUTION_FILE ]]; then
  echo "using existing Elasticsearch Relay distribution file $RELAY_DISTRIBUTION_FILE"
else
  echo "downloading Elasticsearch Relay distribution file"
  curl -o $RELAY_DISTRIBUTION_FILE -L $RELAY_DISTRIBUTION_SRC
fi


# base on schub java image
echo "Creating temporary build container $RELAY_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $RELAY_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash


# install tomcat
echo "Installing Tomcat 7, removing clutter"
sudo docker exec -i -t $RELAY_CONTAINER_NAME mkdir /home/es-relay/
sudo docker cp $TOMCAT_DISTRIBUTION_FILE $RELAY_CONTAINER_NAME:/home/es-relay/tomcat7.tar.gz
sudo docker exec -i -t $RELAY_CONTAINER_NAME sh -c "cd /home/es-relay/ && tar -xzf tomcat7.tar.gz"
sudo docker exec -i -t $RELAY_CONTAINER_NAME rm /home/es-relay/tomcat7.tar.gz
sudo docker exec -i -t $RELAY_CONTAINER_NAME sh -c "cd /home/es-relay/ && mv apache-tomcat-$TOMCAT_VERSION/* ./"
sudo docker exec -i -t $RELAY_CONTAINER_NAME rm -r /home/es-relay/apache-tomcat-$TOMCAT_VERSION/
sudo docker exec -i -t $RELAY_CONTAINER_NAME sh -c "rm -r /home/es-relay/webapps/*"

# install Elasticsearch Wrapper into tomcat
echo "Deploying Elasticsearch Wrapper into Tomcat"
sudo docker exec -i -t $RELAY_CONTAINER_NAME mkdir /home/es-relay/webapps/es-relay/
sudo docker cp $RELAY_DISTRIBUTION_FILE $RELAY_CONTAINER_NAME:/home/es-relay/webapps/es-relay/es-relay.war
sudo docker exec -i -t $RELAY_CONTAINER_NAME sh -c "cd /home/es-relay/webapps/es-relay/ && unzip es-relay.war"
sudo docker exec -i -t $RELAY_CONTAINER_NAME rm /home/es-relay/webapps/es-relay/es-relay.war


# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $RELAY_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $RELAY_CONTAINER_NAME:/
done


# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $RELAY_CONTAINER_NAME $RELAY_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $RELAY_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $RELAY_CONTAINER_NAME
fi