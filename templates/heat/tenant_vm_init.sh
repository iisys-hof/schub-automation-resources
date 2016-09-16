#!/bin/bash

# download and unpack init scripts
mkdir -p /home/ubuntu/init/
cd /home/ubuntu/init/
curl -o scripts.tar.gz http://10.8.0.6/artifactory/software-snapshot-local/schub-vm-init-scripts-SNAPSHOT.tar.gz
tar -xzf scripts.tar.gz
rm scripts.tar.gz

# prepare initscripts for next start
cp rc.local.slave /etc/rc.local

# build/inject base configuration script
echo "#!/bin/bash" > config.sh
echo "export INSTALL_REVERSE_PROXY=INSERT_REVERSE_PROXY_ACTIVE_HERE" >> config.sh
echo "export DOCKER_REGISTRY=INSERT_DOCKER_REGISTRY_HERE" >> config.sh
echo "export TENANT_NAME=INSERT_TENANT_NAME_HERE" >> config.sh
echo "export VM_MESOS_NUMBER=INSERT_TENANT_VM_NAME_HERE" >> config.sh
echo "export ZOOKEEPER_SERVERS=zk://INSERT_ZOOKEEPER_SERVERS_HERE/mesos" >> config.sh
echo "export WEAVE_PEERS=\"INSERT_WEAVE_PEERS_HERE\"" >> config.sh
echo "export WEAVE_PASSWORD=INSERT_WEAVE_PASSWORD_HERE" >> config.sh
echo "export WEAVE_HOST_ADDRESS=INSERT_WEAVE_HOST_ADDRESS_HERE" >> config.sh
echo "export WEAVE_NETWORK=INSERT_WEAVE_NETWORK_HERE" >> config.sh
echo "export WEAVE_BRIDGE_SUBNET=INSERT_WEAVE_VM_NETWORK_HERE" >> config.sh
echo "export INSTALL_PROMETHEUS=INSERT_PROMETHEUS_ACTIVE_HERE" >> config.sh
echo "export CONSUL_DATACENTER_NAME=INSERT_CONSUL_DATACENTER_HERE" >> config.sh
echo "export CONSUL_PEERS=\\\"INSERT_CONSUL_PEER_HERE\\\"" >> config.sh
echo "export MESOS_CPU_CORES=INSERT_MESOS_CPU_CORES_HERE" >> config.sh
echo "export MESOS_RAM_MBS=INSERT_MESOS_RAM_MVS_HERE" >> config.sh
echo "export MESOS_DISK_MBS=INSERT_MESOS_DISK_MBS_HERE" >> config.sh
chmod a+x config.sh

# execute first initialization
chown -R ubuntu:ubuntu /home/ubuntu/
su -c 'cd /home/ubuntu/init/ && ./tenant_vm_autostart.sh' ubuntu
