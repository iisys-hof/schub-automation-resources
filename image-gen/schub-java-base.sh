#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration
BASE_IMAGE=ubuntu:14.04

BASE_CONTAINER_NAME=schub-java-base-build

# base on ubuntu 14.04 image
echo "Creating temporary build container $BASE_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $BASE_IMAGE
fi
sudo docker run --name $BASE_CONTAINER_NAME -i -t -d $BASE_IMAGE /bin/bash

# update
echo "Updating container's packages"
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get update
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get upgrade -y
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get dist-upgrade -y

# install essential tools
echo "Installing commonly used utilities"
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get install -y unzip nano curl wget software-properties-common python-software-properties

# install java
echo "Installing Oracle Java 8"
sudo docker exec -i -t $BASE_CONTAINER_NAME add-apt-repository -y ppa:webupd8team/java
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get update
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get install -y oracle-java8-installer

# import CA certificate into system and java keystores
echo "Importing supplied CA certificate"
if [ -e $CA_CERT ]; then
  sudo docker cp $CA_CERT $BASE_CONTAINER_NAME:/usr/local/share/ca-certificates/cacert.crt
  sudo docker exec -i -t $BASE_CONTAINER_NAME update-ca-certificates
  sudo docker cp $CA_CERT $BASE_CONTAINER_NAME:/cacert.pem
  sudo docker exec -i -t $BASE_CONTAINER_NAME keytool -import -trustcacerts -noprompt -alias schub-root -file /cacert.pem -keystore /usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts -storepass changeit
  sudo docker exec -i -t $BASE_CONTAINER_NAME rm /cacert.pem
fi

# basic folder setup
sudo docker exec -i -t $BASE_CONTAINER_NAME mkdir /templates/
sudo docker exec -i -t $BASE_CONTAINER_NAME mkdir /resources/

# insert modified bashrc to circumvent docker bash bug (TERM=xterm)
sudo docker cp $TEMPLATE_REPO_DIRECTORY/schub-java-base/bashrc $BASE_CONTAINER_NAME:/root/.bashrc

# clean up
echo "Clearing Package cache"
sudo docker exec -i -t $BASE_CONTAINER_NAME apt-get clean

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $BASE_CONTAINER_NAME $JAVA_BASE_IMAGE
fi

# stop container
echo "Stopping build container"
sudo docker stop $BASE_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $BASE_CONTAINER_NAME
fi