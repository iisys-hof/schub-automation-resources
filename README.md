# schub-automation-resources
Scripts, templates and misc. for automated setups of SCHub virtual machines and services

Many scripts and templates still have a setup-specific configuration in them.

## Contents:

* config/* - basic configuration examples for infrastructure components (original setup)
* heat/ - Prototype OpenStack Heat Templates
* image-gen/ - Docker Image and tenant database and certificate generation scripts including in-container bash scripts and templates
* templates/* - templates for scripts and configuration files that still require value injection
  * templates/heat/ - OpenStack Heat Template templates
  * templates/mail/ - Mail Server tenant automation scripts and configuration templates
  * templates/marathon/ - Mesos Marathon service definition templates
  * templates/openldap/ - LDAP tenant initialization automation scripts and templates
* VMs/* - Resources for automatic master and tenant VM installation and initialization
  * VMs/cloud-init/ - Cloud Init "user_data" scripts to trigger automatic VM installation or initialization
  * VMs/preparation/ - Scripts and resources for the installation of VMs
  * VMs/schub-vm-scripts/ - Scripts and resources for the per-instance initialization of pre-installed VMs

## Usage:

### Docker Image Generation

Docker image generation - assembly and configuration (default):

* Create a folder and put the contents of "image-gen" inside
* The shared main configuration file is called "config.sh" - you will need to change the values according to your environment
* Most other scripts have some kind of configuration, too, but most default values should be usable
* create directories called "resources", "tmp", "ca" and "cert"
* place an automated certificate authority's sources (especially its openssl.cnf) in the folder "ca"
* place the root CA certificate under "resources/cacert.pem"
* create "resources/binaries/" - this directory will contain automatically downloaded binaries

Important generation scripts:

* Image Generation and General
  * "all.sh" - generates the base image and all service images
  * "config.sh" - shared main configuration script used by other scripts
  * "schub-java-base.sh" - base image generation script
  * "registry-push.sh" - creates an image based on a container and pushes it to a registry
* Utility
  * "autogen-cert.sh" - generate a wildcard certificate for a tenant including a java keystore for tomcat (uses automated CA)
  * "deploy-certificates.sh" - deploys previously generated certificates to a tenant machine
  * "tomcat-keystore.sh" - creates a tomcat keystore with a server certificate based on the tenant's certificate
  * "create-databases.sh" / "drop-databases.sh" - create/drop all required databases for a tenant (remote)
  * "create-ldap-tenant.sh" / "delete-ldap-tenant.sh" - create/delete a LDAP Directory Tree for a tenant (remote)
  * "create-mail-tenant.sh" / "delete-mail-tenant.sh" - create/delete a configuration for the tenant on the mail server (remote)

Usage:

* All scripts must be executed from the root directory you created
* Executing service image generation scripts requires executing the "java-base-image" to be generated and pushed first
* Some utility scripts require parameters if called directly


### Virtual Machine (Image) Generation

This describes how to generate VM images for Master and Tenant VMs and then how to automatically generate configured VMs from those images.

The initialization of Master machines is incomplete and untested at this moment.

Virutal Machine Images:

* Cloud-Init-Script for Master VMs: VMs/cloud-init/autoinstall_master.sh
* Cloud-Init-Script for Tenant VMs: VMs/cloud-init/autoinstall_slave.sh
* These scripts can be configured so that optional components can be installed
* The scripts and resources from VMs/preparation/ need to be put into a tar.gz archive and uploaded to a reachable server
  * The URL inside the Cloud-Init scripts need to point to this file
* To start the installation, copy the contents of the Cloud-Init script into the "Post-Creation"/"Script Data" box when creating a VM in OpenStack Horizon or provide it as "user_data" via an OpenStack Heat template
* The installation is triggered automatically once the machine has started
* The installation includes all the software that is installed directly, but not the docker containers
* The installation progress is logged to /home/ubuntu/install.log
* After the installation has finished, upload a snapshot of the VM as an image

ATTENTION: a maintenance SSH key should be injected into the VM since VMs based on these images are currently only accessible through the key supplied here.

Usable Virtual Machines from Images:

* Cloud-Init-Script for Master VMs: VMs/cloud-init/autoinit_master.sh
* Cloud-Init-Script for Tenant VMs: VMs/cloud-init/autoinit_slave.sh
* These scripts must be configured per instance, fitting the cluster environment
* The scripts and resources from VMs/schub-vm-scripts/ need to be put into a tar.gz archive and uploaded to a reachable server
  * They contain a basic configuration for the cluster in "environment.sh" which might need to be adapted
  * The URL inside the Cloud-Init scripts need to point to this file
* To start the initialization, copy the contents of the Cloud-Init script into the "Post-Creation"/"Script Data" box when creating a VM in OpenStack Horizon or provide it as "user_data" via an OpenStack Heat template
* The initialization configures all installed services and starts them - including any required docker containers
* The initialization progress is logged to /home/ubuntu/init.log
* After the initialization has finished, the VM should have registered itself with the cluster