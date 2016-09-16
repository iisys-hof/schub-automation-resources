#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration
# TODO: share tomcat image with Shindig?
TOMCAT_VERSION=7.0.68

TOMCAT_DISTRIBUTION_SRC=http://apache.openmirror.de/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

TOMCAT_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/tomcat7.tar.gz

CAS_DISTRIBUTION_SRC=$REPO_SERVER/$SOFTWARE_REPO/de/hofuniversity/iisys/schub-cas/4.0.7/schub-cas-4.0.7.war

CAS_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/cas.war

CAS_CONTAINER_NAME=cas-build

CAS_IMAGE_NAME=schub/cas

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/cas/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/cas/*


# download Apache Tomcat 7
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $TOMCAT_DISTRIBUTION_FILE ]]; then
  echo "using existing Tomcat 7 distribution file $TOMCAT_DISTRIBUTION_FILE"
else
  echo "downloading Tomcat 7 distribution file"
  curl -o $TOMCAT_DISTRIBUTION_FILE $TOMCAT_DISTRIBUTION_SRC
fi

# download CAS (custom schub overlay version)
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $CAS_DISTRIBUTION_FILE ]]; then
  echo "using existing CAS distribution file $CAS_DISTRIBUTION_FILE"
else
  echo "downloading CAS distribution file"
  curl -o $CAS_DISTRIBUTION_FILE $CAS_DISTRIBUTION_SRC
fi

# base on schub java image
echo "Creating temporary build container $CAS_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $CAS_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash

# install tomcat
echo "Installing Tomcat 7 and removing clutter"
sudo docker exec -i -t $CAS_CONTAINER_NAME mkdir /home/cas/
sudo docker cp $TOMCAT_DISTRIBUTION_FILE $CAS_CONTAINER_NAME:/home/cas/tomcat7.tar.gz
sudo docker exec -i -t $CAS_CONTAINER_NAME sh -c "cd /home/cas/ && tar -xzf tomcat7.tar.gz"
sudo docker exec -i -t $CAS_CONTAINER_NAME rm /home/cas/tomcat7.tar.gz
sudo docker exec -i -t $CAS_CONTAINER_NAME sh -c "cd /home/cas/ && mv apache-tomcat-$TOMCAT_VERSION/* ./"
sudo docker exec -i -t $CAS_CONTAINER_NAME rm -r /home/cas/apache-tomcat-$TOMCAT_VERSION/
sudo docker exec -i -t $CAS_CONTAINER_NAME sh -c "rm -r /home/cas/webapps/*"


# install CAS into tomcat
echo "Deploying CAS into Tomcat"
sudo docker exec -i -t $CAS_CONTAINER_NAME mkdir /home/cas/webapps/cas/
sudo docker cp $CAS_DISTRIBUTION_FILE $CAS_CONTAINER_NAME:/home/cas/webapps/cas/cas.war
sudo docker exec -i -t $CAS_CONTAINER_NAME sh -c "cd /home/cas/webapps/cas/ && unzip cas.war"
sudo docker exec -i -t $CAS_CONTAINER_NAME rm /home/cas/webapps/cas/cas.war


# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $CAS_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $CAS_CONTAINER_NAME:/
done


# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $CAS_CONTAINER_NAME $CAS_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $CAS_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $CAS_CONTAINER_NAME
fi