#!/bin/bash

# read configuration
echo "Reading environment configuration"
source ./environment.sh

# constants
DOCKER_CONFIG=/etc/default/docker
DOCKER_CONFIG_TEMPLATE=resources/docker_defaults
DOCKER_CONFIG_TMP=tmp/docker_defaults

WEAVE_START_SCRIPT_TEMPLATE=resources/weave.sh

CONSUL_CONFIG=/etc/consul.d/config.json
CONSUL_CONFIG_TEMPLATE=resources/consul_config.json
CONSUL_CONFIG_TMP=tmp/consul_config.json

CONSUL_START_SCRIPT_TEMPLATE=resources/consul.sh

PROMETHEUS_CONFIG=/home/ubuntu/install/prometheus/prometheus.yml
PROMETHEUS_CONFIG_TEMPLATE=resources/prometheus_consul.yml

PROMETHEUS_START_SCRIPT_TEMPLATE=resources/prometheus.sh

# properly set hostame in hosts file
HOSTNAME=`hostname`
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts

# determine external IP
EXTERNAL_IP=`ifconfig eth0  | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# TODO: mount shared storage?

# TODO: pull tenant SSL data?

## setup cluster components

# setup Docker
echo "Configuring and starting docker"
cat $DOCKER_CONFIG_TEMPLATE | sed \
        -e "s!INSERT_DOCKER_REGISTRY_HERE!$DOCKER_REGISTRY!" \
    > $DOCKER_CONFIG_TMP
sudo mv $DOCKER_CONFIG_TMP $DOCKER_CONFIG
sudo service docker restart

# setup Weave
echo "Configuring and starting Weave"
# generate start script
cat $WEAVE_START_SCRIPT_TEMPLATE | sed \
        -e "s!INSERT_WEAVE_PASSWORD_HERE!$WEAVE_PASSWORD!" \
        -e "s!INSERT_WEAVE_NETWORK_HERE!$WEAVE_NETWORK!" \
        -e "s!INSERT_WEAVE_PEERS_HERE!$WEAVE_PEERS!" \
    > $WEAVE_START_SCRIPT
chmod a+x $WEAVE_START_SCRIPT
$WEAVE_START_SCRIPT

# setup Consul
echo "Configuring and starting Consul"
# place start script
cp $CONSUL_START_SCRIPT_TEMPLATE $CONSUL_START_SCRIPT

# create folders
sudo mkdir -p /etc/consul.d/
sudo mkdir -p /var/lib/consul/data/
sudo mkdir -p /usr/share/consul/ui/dist

# create configuration
cat $CONSUL_CONFIG_TEMPLATE | sed \
        -e "s!INSERT_DATACENTER_NAME_HERE!$CONSUL_DATACENTER_NAME!" \
        -e "s!INSERT_EXTERNAL_IP_HERE!$EXTERNAL_IP!" \
        -e "s!INSERT_CONSUL_PEERS_HERE!$CONSUL_PEERS!" \
    > $CONSUL_CONFIG_TMP
sudo mv $CONSUL_CONFIG_TMP $CONSUL_CONFIG

# start
$CONSUL_START_SCRIPT

# setup Registrator
echo "Starting registrator registrator container"
sudo docker run -d \
  --name=registrator \
  --net=host \
  --restart=always \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    -internal \
    -ttl 30 \
    -ttl-refresh 5 \
    -resync 30 \
    consul://localhost:8500

# setup cAdvisor
echo "Starting cAdvisor docker container"
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=4040:8080 \
  --detach=true \
  --name=cadvisor \
  --restart=always \
  google/cadvisor:latest

# setup Prometheus ?
if [[ "$INSTALL_PROMETHEUS" == "true" ]]; then
    echo "Configuring and starting Prometheus"
    
    # configuration
    cp $PROMETHEUS_CONFIG_TEMPLATE $PROMETHEUS_CONFIG
    
    # start script
    cp $PROMETHEUS_START_SCRIPT_TEMPLATE $PROMETHEUS_START_SCRIPT
    
    # start and mark as started
    $PROMETHEUS_START_SCRIPT
fi

## setup Mesos
echo "Configuring and starting Mesos slave"

# general Zookeeper settings
echo "$ZOOKEEPER_SERVERS" > tmp/zk
sudo mv tmp/zk /etc/mesos/zk

# general slave configuration
sudo cp -r resources/mesos-slave/* /etc/mesos-slave/
echo $EXTERNAL_IP > tmp/hostname
sudo cp tmp/hostname /etc/mesos-slave/hostname
sudo mv tmp/hostname /etc/mesos-slave/ip

echo "cpus(*):$MESOS_CPU_CORES;mem(*):$MESOS_RAM_MBS;disk(*):$MESOS_DISK_MBS" > tmp/resources
sudo mv tmp/resources /etc/mesos-slave/resources

# node attributes
sudo mkdir /etc/mesos-slave/attributes
echo "$TENANT_NAME" > tmp/tenant
sudo mv tmp/tenant /etc/mesos-slave/attributes/tenant
echo "$VM_MESOS_NUMBER" > tmp/tenant_vm
sudo mv tmp/tenant_vm /etc/mesos-slave/attributes/tenant_vm

sudo service mesos-slave restart

# setup reverse proxy?
if [[ "$INSTALL_REVERSE_PROXY" == "true" ]]; then
    echo "Configuring and starting reverse proxy"
    # TODO: generate hostnames based on tenant name?
    sudo service nginx restart
fi

# TODO: register with configuration store?

echo "done"
