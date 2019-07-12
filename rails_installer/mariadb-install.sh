#!/bin/bash
set -e

echo "Installing DB server.."
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
sudo rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
sudo yum -y remove MariaDB-Galera-server
sudo yum -y install MariaDB-server MariaDB-client MariaDB-devel MariaDB-shared
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation

mysqladmin -u root -p version

echo "create database $(echo $PROJECT_NAME)_pro; create database $(echo $PROJECT_NAME)_dev; create database $(echo $PROJECT_NAME)_test; create user $(echo $DB_PRO_USER)@localhost identified by '$(echo $DB_PRO_PASS)'; create user $(echo $DB_DEV_USER)@localhost identified by '$(echo $DB_DEV_PASS)'; grant all privileges on $(echo $PROJECT_NAME)_pro.* to $(echo $DB_PRO_USER)@localhost; grant all privileges on $(echo $PROJECT_NAME)_dev.* to $(echo $DB_DEV_USER)@localhost;" | mysql -u root -p
