#!/bin/bash
# initialization
echo "Initializing Elasticsearch"
/init.sh

# start service and log to console
cd /home/elasticsearch/
echo "Starting Elasticsearch as elasticsearch user"
su - elasticsearch -c 'source /home/elasticsearch/heap_size.sh && /home/elasticsearch/bin/elasticsearch'