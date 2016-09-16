#!/bin/bash
# initialization
echo "Initializing Elasticsearch"
/init.sh

# start service and log to console
cd /home/elasticsearch/
echo "Setting heap size"
source heap_size.sh
echo "Starting Elasticsearch"
./bin/elasticsearch