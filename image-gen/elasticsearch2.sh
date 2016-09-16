#!/bin/bash

# setup
echo "reading global configuration"
source ./config.sh

## basic configuration

ES_VERSION=2.2.1

ES_DISTRIBUTION_SRC=https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz

ES_DISTRIBUTION_FILE=$BINARY_REPO_DIRECTORY/elasticsearch2.tar.gz

ES_CONTAINER_NAME=elasticsearch2-build

ES_IMAGE_NAME=schub/elasticsearch2

CONTAINER_INIT_SCRIPTS=$SCRIPT_REPO_DIRECTORY/elasticsearch2/*

CONTAINER_TEMPLATES=$TEMPLATE_REPO_DIRECTORY/elasticsearch2/*


# download Elasticsearch
if [[ "$FORCE_SOURCE_DOWNLOAD" != "true" ]] && [[ -e $ES_DISTRIBUTION_FILE ]]; then
  echo "using existing Elasticsearch 2.x distribution file $ES_DISTRIBUTION_FILE"
else
  echo "downloading Elasticsearch $ES_VERSION distribution file"
  curl -o $ES_DISTRIBUTION_FILE $ES_DISTRIBUTION_SRC
fi


# base on schub java image
echo "Creating temporary build container $ES_CONTAINER_NAME"
if [ "$FORCE_PULL" == "true" ]; then
  sudo docker pull $DOCKER_REGISTRY/$JAVA_BASE_IMAGE
fi
sudo docker run --name $ES_CONTAINER_NAME -i -t -d $DOCKER_REGISTRY/$JAVA_BASE_IMAGE /bin/bash


# install Elasticsearch
echo "Installing Elasticsearch $ES_VERSION"
sudo docker exec -i -t $ES_CONTAINER_NAME mkdir /home/elasticsearch/
sudo docker cp $ES_DISTRIBUTION_FILE $ES_CONTAINER_NAME:/home/elasticsearch/elasticsearch.tar.gz
sudo docker exec -i -t $ES_CONTAINER_NAME sh -c "cd /home/elasticsearch/ && tar -xzf elasticsearch.tar.gz"
sudo docker exec -i -t $ES_CONTAINER_NAME rm /home/elasticsearch/elasticsearch.tar.gz
sudo docker exec -i -t $ES_CONTAINER_NAME sh -c "cd /home/elasticsearch/ && mv elasticsearch-$ES_VERSION/* ./"
sudo docker exec -i -t $ES_CONTAINER_NAME rm -r /home/elasticsearch/elasticsearch-$ES_VERSION/


# install attachment mapper extension
echo "Installing Attachment Mapper Extension"
sudo docker exec -i -t $ES_CONTAINER_NAME sh -c "cd /home/elasticsearch/ && ./bin/plugin install mapper-attachments"

# additional language packs for liferay
echo "Installing Japanese and Chinese language packs"
sudo docker exec -i -t $ES_CONTAINER_NAME sh -c "cd /home/elasticsearch/ && ./bin/plugin install analysis-kuromoji"
sudo docker exec -i -t $ES_CONTAINER_NAME sh -c "cd /home/elasticsearch/ && ./bin/plugin install analysis-smartcn"

# set non-root user (required by ES 2.x)
echo "Creating elasticsearch user"
sudo docker exec -i -t $ES_CONTAINER_NAME useradd elasticsearch
sudo docker exec -i -t $ES_CONTAINER_NAME chown -R elasticsearch:elasticsearch /home/elasticsearch/

# templates, scripts
echo "Inserting configuration templates and scripts"
for f in $CONTAINER_TEMPLATES
do
  sudo docker cp $f $ES_CONTAINER_NAME:/templates/
done

for f in $CONTAINER_INIT_SCRIPTS
do
  sudo docker cp $f $ES_CONTAINER_NAME:/
done

# autopush
if [ "$AUTO_PUSH" == "true" ]; then
  ./registry-push.sh $ES_CONTAINER_NAME $ES_IMAGE_NAME
fi

# stop container
echo "Stopping build container"
sudo docker stop $ES_CONTAINER_NAME

# delete build container
if [ "$DELETE_BUILD_CONTAINERS" == "true" ]; then
  echo "Deleting build container"
  sudo docker rm -f $ES_CONTAINER_NAME
fi