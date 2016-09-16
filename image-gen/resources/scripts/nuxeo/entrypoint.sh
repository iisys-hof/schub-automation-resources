#!/bin/bash
# initialization
echo "Initializing Nuxeo"
/init.sh

# start service and log to console
cd /home/nuxeo/
echo "Starting Nuxeo service"
nuxeoctl start
tail -f /var/log/nuxeo/server.log