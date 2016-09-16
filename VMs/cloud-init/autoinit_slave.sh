#!/bin/bash

# download and unpack init scripts
mkdir -p /home/ubuntu/init/
cd /home/ubuntu/init/
curl -o scripts.tar.gz http://10.8.0.1/artifactory/software-snapshot-local/schub-vm-init-scripts-SNAPSHOT.tar.gz
tar -xzf scripts.tar.gz
rm scripts.tar.gz

# prepare initscripts for next start
cp rc.local.slave /etc/rc.local

# build/inject base configuration script
echo "#!/bin/bash" > config.sh
echo "export INSTALL_REVERSE_PROXY=false" >> config.sh
echo "export DOCKER_REGISTRY=10.8.0.2:5000" >> config.sh
echo "export TENANT_NAME=demo" >> config.sh
echo "export VM_MESOS_NUMBER=three" >> config.sh
echo "export ZOOKEEPER_SERVERS=zk://10.8.0.2:2181,10.8.0.1:2181,10.8.0.3:2181/mesos" >> config.sh
echo "export WEAVE_PEERS=\"10.8.0.1 10.8.0.3\"" >> config.sh
echo "export WEAVE_PASSWORD=weavepw" >> config.sh
echo "export WEAVE_HOST_ADDRESS=10.9.255.1/16" >> config.sh
echo "export WEAVE_NETWORK=10.9.0.0/16" >> config.sh
echo "export WEAVE_BRIDGE_SUBNET=10.9.3.0/24" >> config.sh
echo "export INSTALL_PROMETHEUS=false" >> config.sh
echo "export CONSUL_DATACENTER_NAME=test" >> config.sh
echo "export CONSUL_PEERS=\\\"10.8.0.2\\\"" >> config.sh
echo "export MESOS_CPU_CORES=8" >> config.sh
echo "export MESOS_RAM_MBS=8192" >> config.sh
echo "export MESOS_DISK_MBS=96000" >> config.sh
chmod a+x config.sh

# execute first initialization
chown -R ubuntu:ubuntu /home/ubuntu/
su -c 'cd /home/ubuntu/init/ && ./tenant_vm_autostart.sh' ubuntu > /home/ubuntu/init.log 2>&1 &
