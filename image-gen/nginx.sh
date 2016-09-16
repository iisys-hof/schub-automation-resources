#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration
BASE_IMAGE=ubuntu:14.04

NGINX_CONTAINER_NAME=nginx-build

NGINX_IMAGE_NAME=schub/nginx

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/nginx/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/nginx/*

# base on ubuntu 14.04 image
echo "Creating temporary build container $BASE_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $BASE_IMAGE
fi
sudo docker run --name $NGINX_CONTAINER_NAME -i -t -d $BASE_IMAGE /bin/bash

# update
echo "Updating container's packages"
sudo docker exec -i -t $NGINX_CONTAINER_NAME apt-get update
sudo docker exec -i -t $NGINX_CONTAINER_NAME apt-get upgrade -y
sudo docker exec -i -t $NGINX_CONTAINER_NAME apt-get dist-upgrade -y

# install essential tools
echo "Installing nginx and commonly used utilities"
sudo docker exec -i -t $NGINX_CONTAINER_NAME apt-get install -y nginx unzip nano curl wget software-properties-common python-software-properties

# import CA certificate into system and java keystores
echo "Importing supplied CA certificate"
if [ -e $CA_CERT ]; then
  sudo docker cp $CA_CERT $NGINX_CONTAINER_NAME:/usr/local/share/ca-certificates/cacert.crt
  sudo docker exec -i -t $NGINX_CONTAINER_NAME update-ca-certificates
fi

# basic folder setup
sudo docker exec -i -t $NGINX_CONTAINER_NAME mkdir /templates/
sudo docker exec -i -t $NGINX_CONTAINER_NAME mkdir /resources/
sudo docker exec -i -t $NGINX_CONTAINER_NAME mkdir /home/nginx/

# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $NGINX_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $NGINX_CONTAINER_NAME:/
done

# clean up
echo "Clearing Package cache"
sudo docker exec -i -t $NGINX_CONTAINER_NAME apt-get clean

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $NGINX_CONTAINER_NAME $NGINX_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $NGINX_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $NGINX_CONTAINER_NAME
fi