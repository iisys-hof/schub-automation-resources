#!/bin/bash
# initialization
echo "Initializing Nginx"
/init.sh

# start service and log to console
cd /home/nginx/
echo "Starting Nginx server"
/etc/init.d/nginx start
tail -f /var/log/nginx/error.log