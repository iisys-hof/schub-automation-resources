#!/bin/bash

# script for general configuration, shared by all nodes

# TODO: actually read configuration from cloud config or configuration store

# read local configuration
source ./config.sh

mkdir tmp

## shared
export CONSUL_START_SCRIPT=/home/ubuntu/consul.sh

export PROMETHEUS_START_SCRIPT=/home/ubuntu/prometheus.sh

# zookeeper peers (for mesos)
export ZOOKEEPER_SERVERS=zk://10.8.0.2:2181,10.8.0.1:2181,10.8.0.3:2181/mesos

# initial consul peers
export CONSUL_SERVERS=10.8.0.2

## slaves only
export WEAVE_START_SCRIPT=/home/ubuntu/weave.sh

# docker registry to use
export DOCKER_REGISTRY=127.0.0.1:5000
