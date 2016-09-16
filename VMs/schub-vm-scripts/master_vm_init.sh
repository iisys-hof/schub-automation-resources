#!/bin/bash

# read configuration
echo "Reading environment configuration"
source ./environment.sh

# properly set hostame in hosts file
HOSTNAME=`hostname`
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts

# constants
DOCKER_CONFIG=/etc/default/docker
DOCKER_CONFIG_TEMPLATE=resources/docker_defaults_master

CONSUL_CONFIG=/etc/consul.d/config.json
CONSUL_CONFIG_TEMPLATE=resources/consul_config.json
CONSUL_CONFIG_TMP=tmp/consul_config.json

CONSUL_START_SCRIPT_TEMPLATE=resources/consul.sh

PROMETHEUS_CONFIG=/home/ubuntu/install/prometheus/prometheus.yml
PROMETHEUS_CONFIG_TEMPLATE=resources/prometheus_consul.yml

PROMETHEUS_START_SCRIPT_TEMPLATE=resources/prometheus.sh

# TODO: mount shared storage?


## setup cluster components

# setup Docker
echo "Configuring and starting docker"
cat $DOCKER_CONFIG_TEMPLATE | sed \
        -e "s!INSERT_WEAVE_BRIDGE_SUBNET_HERE!$WEAVE_BRIDGE_SUBNET!" \
        -e "s!INSERT_DOCKER_REGISTRY_HERE!$SERVER_NAME!" \
    > $DOCKER_CONFIG
sudo service docker restart

# setup consul
echo "Configuring and starting Consul"
# place start script
cp $CONSUL_START_SCRIPT_TEMPLATE $CONSUL_START_SCRIPT

# create folders
sudo mkdir -p /etc/consul.d/
sudo mkdir -p /var/lib/consul/data/
sudo mkdir -p /usr/share/consul/ui/dist

# determine external IP
EXTERNAL_IP=`ifconfig eth0  | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# create configuration
cat $CONSUL_CONFIG_TEMPLATE | sed \
        -e "s!INSERT_DATACENTER_NAME_HERE!$CONSUL_DATACENTER_NAME!" \
        -e "s!INSERT_EXTERNAL_IP_HERE!$EXTERNAL_IP!" \
        -e "s!INSERT_CONSUL_PEERS_HERE!$CONSUL_PEERS!" \
    > $CONSUL_CONFIG_TMP
sudo cp $CONSUL_CONFIG_TMP CONSUL_CONFIG

# start and mark as started
$CONSUL_START_SCRIPT
export CONSUL_STARTED=true

# setup zookeeper
echo "Configuring and starting Zookeeper"

sudo service zookeeper restart


# setup mesos
echo "Configuring and starting Mesos master"

sudo service mesos-master restart

# setup marathon
echo "Configuring and starting Marathon"

sudo service marathon restart

# setup prometheus?
if [[ "$INSTALL_PROMETHEUS" == "true" ]]; then
    echo "Configuring and starting Prometheus"
    
    # configuration
    cp $PROMETHEUS_CONFIG_TEMPLATE $PROMETHEUS_CONFIG
    
    # start script
    cp $PROMETHEUS_START_SCRIPT_TEMPLATE $PROMETHEUS_START_SCRIPT
    
    # start and mark as started
    $PROMETHEUS_START_SCRIPT
    export PROMETHEUS_STARTED=true
fi

# setup grafana?
if [[ "$INSTALL_GRAFANA" == "true" ]]; then
    "Starting Grafana Docker container"
    # TODO: requires a configuration file
    sudo docker run -d -p 3000:3000 \
        --name grafana \
        -v /home/ubuntu/grafana/etc:/etc/grafana \
        -v /home/ubuntu/grafana/var:/var/lib/grafana \
        -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
        --restart=always \
        grafana/grafana
fi

# setup docker registry?
if [[ "$INSTALL_REGISTRY" == "true" ]]; then
    "Starting Docker Registry Docker Container"
    sudo mkdir -p /mnt/data/registry
    docker run -d \
        -p 5000:5000 \
        --restart=always \
        --name registry \
        -v /mnt/data/registry:/var/lib/registry \
        registry:2
fi


# setup reverse proxy?
if [[ "$INSTALL_REVERSE_PROXY" == "true" ]]; then
    "Configuring and starting reverse proxy"
    # TODO: hook up tenant proxies?
    # TODO: hook up cluster-wide services?
    sudo service nginx restart
fi

# TODO: register with configuration store

echo "done"
