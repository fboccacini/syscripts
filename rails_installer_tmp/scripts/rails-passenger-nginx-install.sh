#!/bin/bash
set -e

sudo yum -y install nodejs npm
gem install rails passenger
rvmsudo passenger-install-nginx-module

cd $INSTALLER_PATH
sudo chmod +x nginx
sudo cp nginx /etc/init.d
sudo /sbin/chkconfig nginx on
