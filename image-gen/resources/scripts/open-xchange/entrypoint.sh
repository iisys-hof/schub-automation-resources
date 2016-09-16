#!/bin/bash
# initialization
echo "Initializing Open-Xchange"
/init.sh

cd /home/open-xchange/
# start proxying apache
echo "Starting Apache Httpd"
/etc/init.d/apache2 start

# start service and log to console
#/etc/init.d/open-xchange start

echo "Open-Xchange was already started during initialization"

tail --follow=name --retry /var/log/open-xchange/open-xchange-console.log &
tail --follow=name --retry /var/log/open-xchange/open-xchange.log.0 &
tail --follow=name --retry /var/log/open-xchange/open-xchange-osgi.log