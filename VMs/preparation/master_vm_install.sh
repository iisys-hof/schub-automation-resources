#!/bin/bash

# read configuration
echo "Reading environment configuration"
source ./environment.sh

# import Schub CA certificate
echo "Importing SCHub CA certificate"
curl -o cacert.pem $SCHUB_CA_CERT
sudo cp cacert.pem /usr/local/share/ca-certificates/cacert.crt
sudo update-ca-certificates

# set a better apt mirror list
sudo cp resources/apt.sources.list /etc/apt/sources.list

echo "Updating package sources"
sudo apt-get -y update

echo "Updating base system"
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade

## install utilities
echo "Installing utilities"
# mysql-client?
sudo apt-get install -y unzip software-properties-common python-software-properties

## prepare environment
echo "Preparing environment"
mkdir tmp

# upgrade to newer kernel
echo "Upgrading to Kernel 4.2"
sudo apt-get install -y --install-recommends linux-generic-lts-wily

## install base services
# install docker
echo "Installing Docker"
wget -qO- https://get.docker.com/ | sh

# install consul
echo "Installing Consul"
cd tmp
curl -o consul.zip $CONSUL_SRC
unzip consul.zip
rm consul.zip
chmod a+x consul
sudo mv consul /usr/local/bin/consul
cd ..

# install zookeeper
echo "Installing Zookeeper"
sudo apt-get install -y zookeeper zookeeperd

# install java 8 for marathon
echo "Installing OpenJDK 8"
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get -y update
sudo apt-get install -y openjdk-8-jre-headless

# TODO: import certificate for 'custom' java?

# install mesos and marathon
echo "Installing Mesos and Marathon"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update
sudo apt-get -y install mesos marathon

# disable automatically installed mesos-slave
echo "Disabling Mesos slave"
sudo service mesos-slave stop
sudo sh -c "echo manual > /etc/init/mesos-slave.override"

## install optional services
# prometheus
if [[ "$INSTALL_PROMETHEUS" == "true" ]]; then
    echo "Installing Prometheus"
    mkdir prometheus
    cd prometheus
    curl -o prometheus.tar.gz $PROMETHEUS_SRC
    tar -xzf prometheus.tar.gz
    rm prometheus.tar.gz
    mv prometheus-$PROMETHEUS_VERSION.linux-amd64/* ./
    rm -r prometheus-$PROMETHEUS_VERSION.linux-amd64
    cd ..
fi

# nginx reverse proxy
if [[ "$INSTALL_REVERSE_PROXY" == "true" ]]; then
    echo "Installing nginx"
    sudo apt-get install -y nginx
fi

## cleanup
echo "cleaning up"
rm -r tmp
sudo apt-get clean

# TODO: disable system autostarts?

echo "done"