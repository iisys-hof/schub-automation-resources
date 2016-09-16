#!/bin/bash
# initialization
echo "Open-Xchange was already initialized"
#/init.sh

cd /home/open-xchange/
# start proxying apache
echo "Starting Apache Httpd"
/etc/init.d/apache2 start

# start service and log to console
echo "Starting Open-Xchange service"
/etc/init.d/open-xchange start

tail --follow=name --retry /var/log/open-xchange/open-xchange-console.log &
tail --follow=name --retry /var/log/open-xchange/open-xchange.log.0 &
tail --follow=name --retry /var/log/open-xchange/open-xchange-osgi.log