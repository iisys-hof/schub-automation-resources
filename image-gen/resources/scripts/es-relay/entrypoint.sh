#!/bin/bash
# initialization
echo "Initializing Elasticsearch Relay"
/init.sh

# start service and log to console
cd /home/es-relay/
echo "Starting Elasticsearch Relay Tomcat server"
./bin/startup.sh
tail -f logs/catalina.out