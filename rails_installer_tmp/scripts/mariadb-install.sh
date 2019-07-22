#!/bin/bash

hash mysqld 2>/dev/null

if [ $? -eq 0 ]
then
  echo
  echo "Mysql ($(mysqld --version)) is already installed. Skipping installation."
  echo
  exit 0
fi

set -e

PROJECT_NAME=$1

echo "Installing DB server.."
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
sudo rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

REMOVE='x'
while [[ $REMOVE != "y" ]] && [[ $REMOVE != "n" ]] && [[ $REMOVE != "Y" ]] && [[ $REMOVE != "N" ]] && [[ $REMOVE != '' ]]
do
  echo -n "I'm gonna need to remove MariaDB-Galera-server (if installed). Is it ok? [Y/n]  "
  read REMOVE
  echo
done

if [[ $REMOVE = "y" ]] || [[ $REMOVE = "Y" ]] || [[ $REMOVE = '' ]]
then

  sudo yum -y remove MariaDB-Galera-server

else
  echo "To install MariaDB server, we must remove MariaDB-Galera server. Please manage this conflict."
  echo
  exit 1
fi

sudo yum -y install MariaDB-server MariaDB-client MariaDB-devel MariaDB-shared
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation

# mysqladmin -u root -p version
mysqld --version
