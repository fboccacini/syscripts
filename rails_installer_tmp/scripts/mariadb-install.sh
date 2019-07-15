#!/bin/bash
set -e

PROJECT_NAME=$1

echo "Installing DB server.."
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
sudo rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
sudo yum -y remove MariaDB-Galera-server
sudo yum -y install MariaDB-server MariaDB-client MariaDB-devel MariaDB-shared
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation

mysqladmin -u root -p version
