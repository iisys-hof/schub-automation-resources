#!/bin/bash

# download and unpack init scripts
mkdir -p /home/ubuntu/install/
cd /home/ubuntu/install/
curl -o scripts.tar.gz http://10.8.0.1/artifactory/software-snapshot-local/schub-vm-install-scripts-SNAPSHOT.tar.gz
tar -xzf scripts.tar.gz
rm scripts.tar.gz

echo "#!/bin/bash" > config.sh
echo "export INSTALL_REVERSE_PROXY=false" >> config.sh
echo "export INSTALL_PROMETHEUS=false" >> config.sh
chmod a+x config.sh

# base installation
./tenant_vm_install.sh > /home/ubuntu/install.log 2>&1
