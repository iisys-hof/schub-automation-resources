#!/bin/bash
# initialization
echo "Initializing Liferay"
/init.sh

# start libreoffice daemon for document previews
echo "Starting LibreOffice server"
soffice --headless --accept="socket,host=127.0.0.1,port=8100;urp;" --nofirststartwizard &

# start service and log to console
cd /home/liferay/tomcat-8.0.32/
echo "Starting Liferay Tomcat"
./bin/startup.sh
tail -f logs/catalina.out