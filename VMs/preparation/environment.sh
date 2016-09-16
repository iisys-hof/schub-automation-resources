#!/bin/bash

# TODO: actually read configuration from cloud config or configuration store

# read local configuration
source ./config.sh

## general configuration

export SCHUB_CA_CERT="http://10.8.0.1/artifactory/software-release-local/schub-cacert.pem"

export CONSUL_SRC="https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip"

export PROMETHEUS_VERSION="0.17.0"
export PROMETHEUS_SRC="https://github.com/prometheus/prometheus/releases/download/$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

export PROMETHEUS_VERSION="0.17.0"
export PROMETHEUS_SRC="https://github.com/prometheus/prometheus/releases/download/$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

export WEAVE_SRC="https://github.com/weaveworks/weave/releases/download/latest_release/weave"


## shared

export INSTALL_REVERSE_PROXY=true

