#!/bin/bash

# read configuration
source ./environment.sh

# check for previous initialization
source ./init-marker.sh

# only call inizialization once
if [[ "$INITIALIZED" != "true" ]]; then
    echo "Initializing Tenant machine"
    ./tenant_vm_init.sh
    echo "export INITIALIZED=true" > init-marker.sh
    chmod a+x init-marker.sh

    # mark services started by the init script as started
    export WEAVE_STARTED=true
    export CONSUL_STARTED=true
    export PROMETHEUS_STARTED=true
fi

# start Weave if not yet started
if [[ "$WEAVE_STARTED" != "true" ]]; then
    echo "starting Weave"
    $WEAVE_START_SCRIPT
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
