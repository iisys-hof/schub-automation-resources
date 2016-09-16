#!/bin/bash
# initialization
echo "Initializing Apache Shindig"
/init.sh

# start service and log to console
cd /home/shindig/
echo "Starting Apache Shindig Tomcat server"
./bin/startup.sh
tail -f logs/catalina.out