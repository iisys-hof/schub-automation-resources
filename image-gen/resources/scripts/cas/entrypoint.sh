#!/bin/bash
# initialization
echo "Initializing CAS"
/init.sh

# start service and log to console
cd /home/cas/
echo "Starting CAS Tomcat server"
./bin/startup.sh
tail -f logs/catalina.out