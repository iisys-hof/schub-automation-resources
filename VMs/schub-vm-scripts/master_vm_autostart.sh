#!/bin/bash

# read configuration
source ./environment.sh

# check for previous initialization
source ./init-marker.sh

# only call inizialization once
if [[ "$INITIALIZED" != "true" ]]; then
    echo "Initializing Master machine"
    ./master_vm_init.sh
    echo "export INITIALIZED=true" > init-marker.sh
    chmod a+x init-marker.sh
fi

# start Consul if not yet started
if [[ "$CONSUL_STARTED" != "true" ]]; then
    echo "starting Consul"
    $CONSUL_START_SCRIPT
fi

# start Prometheus if activated and not yet started
if [[ "$INSTALL_PROMETHEUS" == "true" ]]; then
    if [[ "$PROMETHEUS_STARTED" != "true" ]]; then
        echo "starting Prometheus"
        $PROMETHEUS_START_SCRIPT
    fi
fi
