#!/bin/bash
# initialization
echo "Initializing Websocket Server"
/init.sh

# start service and log to console
cd /home/websocket-server/
echo "Starting Websocket Server"
./websocket-server.sh start
tail -f server.log