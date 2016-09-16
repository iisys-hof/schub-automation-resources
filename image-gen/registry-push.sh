#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## input values
CONTAINER_NAME=$1

IMAGE_NAME=$2

if [ -z "$CONTAINER_NAME" ]; then
        echo "ERROR: No container name specified"
        return
fi

if [ -z "$IMAGE_NAME" ]; then
        echo "ERROR: No image name specified"
        return
fi

# TODO: support for tags other than "latest"?

# commit
echo "Committing Docker Container $CONTAINER_NAME to image $IMAGE_NAME:latest"
sudo docker commit $CONTAINER_NAME $IMAGE_NAME:latest

# tag
echo "Tagging image as $DOCKER_REGISTRY/$IMAGE_NAME:latest"
sudo docker tag $IMAGE_NAME:latest $DOCKER_REGISTRY/$IMAGE_NAME:latest

# push
echo "Pushing image to registry"
sudo docker push $DOCKER_REGISTRY/$IMAGE_NAME:latest

# delete locally generated images
if [ "$DELETE_BUILD_IMAGES" == "true" ]; then
  echo ""Deleting temporary images
  sudo docker rmi $IMAGE_NAME $DOCKER_REGISTRY/$IMAGE_NAME
fi