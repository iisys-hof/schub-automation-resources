#!/bin/bash

#setup
echo "reading global configuration"
source ./config.sh

# websocket server with shindig serverroutines in a folder called "websocket-server" in a tar.gz
WSS_DISTRIBUTION_SRC=$REPO_SERVER/$SOFTWARE_REPO/websocket-server-0.5.2-2.5.2-15.tar.gz

WSS_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/websocket-server.tar.gz

# TODO: package shindig serverroutines separately

WSS_CONTAINER_NAME=websocket-server-build

WSS_IMAGE_NAME=schub/websocket-server

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/websocket-server/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/websocket-server/*


# download Neo4j Websocket Server
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $WSS_DISTRIBUTION_FILE ]]; then
  echo "using existing Neo4j Websocket Server bundle distribution file $WSS_DISTRIBUTION_FILE"
else
  echo "downloading Neo4j Websocket Server bundle distribution file"
  curl -o $WSS_DISTRIBUTION_FILE $WSS_DISTRIBUTION_SRC
fi


# base on schub java image
echo "Creating temporary build container $WSS_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $WSS_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash

# install websocket server
echo "Installing Websocket Server bundle"
sudo docker exec -i -t $WSS_CONTAINER_NAME mkdir /home/websocket-server/
sudo docker exec -i -t $WSS_CONTAINER_NAME mkdir /data/
sudo docker cp $WSS_DISTRIBUTION_FILE $WSS_CONTAINER_NAME:/home/websocket-server/websocket-server.tar.gz
sudo docker exec -i -t $WSS_CONTAINER_NAME sh -c "cd /home/websocket-server/ && tar -xzf websocket-server.tar.gz"
sudo docker exec -i -t $WSS_CONTAINER_NAME rm /home/websocket-server/websocket-server.tar.gz
sudo docker exec -i -t $WSS_CONTAINER_NAME sh -c "cd /home/websocket-server/ && mv websocket-server/* ./"
sudo docker exec -i -t $WSS_CONTAINER_NAME rm -r /home/websocket-server/websocket-server/


# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $WSS_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $WSS_CONTAINER_NAME:/
done

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $WSS_CONTAINER_NAME $WSS_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $WSS_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $WSS_CONTAINER_NAME
fi