#!/bin/bash

set -e

CONF_PATH=$(sudo find / | grep -E "nginx\.conf$")
if [ -n "$CONF_PATH" ]
then

  echo "Nginx configuration found in $CONF_PATH. Skipping installation."
  echo
  exit

fi

echo
echo "Installing passenger, nginx and rails as $(whoami).."
echo

# Get installer path to find specific scripts
ABS_PATH=$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")
INSTALLER_PATH=$(dirname $ABS_PATH)

# Install dependencies
sudo yum -y install nodejs npm

# Install gems
gem install rails passenger

# Compile nginx
rvmsudo passenger-install-nginx-module

# Get installation path
CONF_PATH=$(sudo find / | grep -E "nginx\.conf$")
NGINX_PATH=$(dirname $CONF_PATH | sed 's/\/conf//')
echo "Nginx installation path: $NGINX_PATH"
echo

# Copy nginx service script and configure it
sudo chmod +x $INSTALLER_PATH/nginx
sudo cp $INSTALLER_PATH/nginx /etc/init.d
sudo sed -i "s/\/opt\/nginx/$NGINX_PATH/g" /etc/init.d/nginx

sudo /sbin/chkconfig nginx on
