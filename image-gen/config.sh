#!/bin/bash

## general environment configuration
export REPO_SERVER=http://10.8.0.6/artifactory

export LIBRARY_REPO=libs-release-local

export LIBRARY_SNAPSHOT_REPO=libs-snapshot-local

export SOFTWARE_REPO=software-release-local

export SOFTWARE_SNAPSHOT_REPO=software-snapshot-local

export RESOURCE_DIRECTORY=resources

export SCRIPT_REPO_DIRECTORY=$RESOURCE_DIRECTORY/scripts

export TEMPLATE_REPO_DIRECTORY=$RESOURCE_DIRECTORY/templates

export BINARY_REPO_DIRECTORY=$RESOURCE_DIRECTORY/binaries

export DOCKER_REGISTRY=127.0.0.1:5000

export TMP_DIRECTORY=tmp

export CA_CERT=$RESOURCE_DIRECTORY/cacert.pem

export INTERMEDIATE_CERT=$RESOURCE_DIRECTORY/intermediate.pem

export SSH_MAINTENANCE_USER=ubuntu
export SSH_MAINTENANCE_KEY=ssh/schub-maintenance.pem

export MARIADB_USER=root
export MARIADB_PASS=secret
export MARIADB_HOST=10.8.0.3
export MARIADB_PORT=3306

export MAIL_HOST=10.8.0.4
export MAIL_SSH_USER=ubuntu
export MAIL_SSH_KEY=ssh/schub-maintenance.pem

export LDAP_HOST=10.8.0.5
export LDAP_SSH_USER=ubuntu
export LDAP_SSH_KEY=ssh/schub-maintenance.pem

## behavior settings
export FORCE_PULL=true

export FORCE_SOURCE_DOWNLOAD=false

export AUTO_PUSH=true

export DELETE_BUILD_CONTAINERS=true

export DELETE_BUILD_IMAGES=true

## image settings
export JAVA_BASE_IMAGE=schub/java-base

## software settings
export MARIADB_DRIVER_SRC=http://central.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/1.3.6/mariadb-java-client-1.3.6.jar

export MARIADB_DRIVER_FILE=$BINARY_REPO_DIRECTORY/mariadb-java-client.jar


# filesystem preparation
mkdir -p $BINARY_REPO_DIRECTORY
mkdir -p $TMP_DIRECTORY
