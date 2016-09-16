#!/bin/bash
# initialization
echo "Initializing Camunda"
/init.sh

# start service and log to console
cd /home/camunda/server/apache-tomcat-8.0.24/
echo "Starting Camunda Tomcat server"
./bin/startup.sh
tail -f logs/catalina.out