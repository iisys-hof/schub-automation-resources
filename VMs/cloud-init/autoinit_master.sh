#!/bin/bash

# download and unpack init scripts
mkdir -p /home/ubuntu/init/
cd /home/ubuntu/init/
curl -o scripts.tar.gz http://10.8.0.1/artifactory/software-snapshot-local/schub-vm-init-scripts-SNAPSHOT.tar.gz
tar -xzf scripts.tar.gz
rm scripts.tar.gz

# prepare initscripts for next start
cp rc.local.master /etc/rc.local

# build/inject local configuration script
echo "#!/bin/bash" > config.sh
echo "export INSTALL_REVERSE_PROXY=false" >> config.sh
echo "export ZOOKEEPER_ID=4" >> config.sh
echo "export ZOOKEEPER_SERVERS=zk://10.8.0.2:2181,10.8.0.1:2181,10.8.0.3:2181/mesos" >> config.sh
echo "export INSTALL_REGISTRY=false" >> config.sh
echo "export INSTALL_GRAFANA=false" >> config.sh
echo "export INSTALL_PROMETHEUS=false" >> config.sh
chmod a+x config.sh

# execute first initialization
chown -R ubuntu:ubuntu /home/ubuntu/
su -c 'cd /home/ubuntu/init/ && ./master_vm_autostart.sh' ubuntu > /home/ubuntu/init.log 2>&1 &
