#!/bin/bash
## constants
ES_CONF="/home/elasticsearch/config/elasticsearch.yml"
ES_CONF_TEMPLATE="/templates/elasticsearch.yml"
ES_CONF_TMP="/tmp/elasticsearch.yml"

HEAP_CONF="/home/elasticsearch/heap_size.sh"
HEAP_CONF_TEMPLATE="/templates/heap_size.sh"

## read environment variables
# check and set default values

if [ -z "$CLUSTER_NAME" ]; then
        CLUSTER_NAME=tenant-cluster
        echo "WARNING: No cluster name supplied, using default: $CLUSTER_NAME"
fi

if [ -z "$NODE_NAME" ]; then
        NODE_NAME=tenant-elasticsearch
        echo "WARNING: No node name supplied, using default: $NODE_NAME"
fi

if [ -z "$HEAP_SIZE" ]; then
        HEAP_SIZE=256M
        echo "WARNING: No Java heap size supplied, using default: $HEAP_SIZE"
fi

## replace variables in template
echo "Configuring Elasticsearch"
cat $ES_CONF_TEMPLATE | sed \
        -e "s/INSERT_CLUSTER_NAME_HERE/$CLUSTER_NAME/" \
        -e "s/INSERT_NODE_NAME_HERE/$NODE_NAME/" \
        > $ES_CONF_TMP

cat $HEAP_CONF_TEMPLATE | sed \
        -e "s/INSERT_HEAP_SIZE_HERE/$HEAP_SIZE/" \
        > $HEAP_CONF

## replace old configuration files
echo "Replacing old configuration file"
cp $ES_CONF_TMP $ES_CONF

# remove temporary files
echo "Removing temporary files"
rm $ES_CONF_TMP

echo "End of Elasticsearch initialization"
