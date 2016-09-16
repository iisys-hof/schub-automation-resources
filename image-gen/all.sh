#!/bin/bash

# preparation
echo "Generating SChub base java image"
./schub-java-base.sh

# services
echo "Generating Camunda image"
./camunda.sh
echo "Generating CAS image"
./cas.sh
echo "Generating Elasticsearch 1.x image"
./elasticsearch.sh
echo "Generating Elasticsearch 2.x image"
./elasticsearch2.sh
echo "Generating Liferay image"
./liferay.sh
echo "Generating Nuxeo image"
./nuxeo.sh
echo "Generating Open-Xchange image"
./open-xchange.sh
echo "Generating Apache Shindig image"
./shindig.sh
echo "Generating Websocket Server image"
./websocket-server.sh
echo "Generating Nginx Server image"
./nginx.sh
echo "Generating Elasticsearch Relay image"
./es-relay.sh