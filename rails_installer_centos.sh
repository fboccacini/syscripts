#!/bin/bash

set -e

echo "+-----------------------------------------------------------------+"
echo "| Ruby-on-Rails installer                                         |"
echo "|                                                                 |"
echo "| RVM, Nginx, Passenger, bundler, MariaDB/Postgresql and git      |"
echo "|                                                                 |"
echo "| Please have the following informations handy:                   |"
echo "| Project name                                                    |"
echo "| Git account credentials, local web server user credentials,     |"
echo "| DB user credentials                                             |"
echo "+-----------------------------------------------------------------+"
echo
echo

# Get informations
echo "Project name:"
read PROJECT_NAME

echo "User that will execute the server:"
read NEW_USER

echo "Password:"
read NEW_PASSWD

echo "DB production user:"
read DB_PRO_USER

echo "Password:"
read DB_PRO_PASS

echo "DB development user:"
read DB_DEV_USER

echo "Password:"
read DB_DEV_PASS

echo "DB test user:"
read DB_TEST_USER

echo "Password:"
read DB_TEST_PASS

echo "Adding user: $NEW_USER.."
sudo useradd -m -p $NEW_PASSWD $NEW_USER
echo "User $NEW_USER created."
echo

# Get installer path for later use
INSTALLER_PATH=$(pwd)

# Create a folder to contain all needed packages
mkdir -p installation
cd installation
INST_DIR=$(pwd)

# Enable epel and update system
echo "Upgrading system.."
sudo yum -y --enablerepo=extras install epel-release
sudo yum -y upgrade
echo

# Install git, wget and curl
echo "Installing Git, wget and Curl.."
sudo yum -y install git wget curl-devel
echo

# DB choice
echo "Which DB server would you like to install?"
echo "    1 - MariaDB"
echo "    2 - Postresql"
read DB_TYPE

if [$DB_TYPE = '1']
then
  # Install MariaDB server
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
else
  # Install Postgresql server
  echo "Installing Postgreql server.."

fi

# Install RVM
echo "Installing RVM.."
sudo groupadd rvm
sudo usermod -a -G rvm root
sudo usermod -a -G rvm $NEW_USER
sudo usermod -a -G wheel $NEW_USER

# If it's a virtualbox vm add the user to vboxsf too
if grep -q vboxsf /etc/group
then
     sudo usermod -a -G vboxsf $NEW_USER
fi


gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -L https://get.rvm.io | sudo bash -s stable --ruby
source /etc/profile.d/rvm.sh

# Change user
echo "Become $NEW_USER to install gems:"
su $NEW_USER
cd $INST_DIR

# Get latest ruby version and install it
RUBY_VER=$(rvm list known | grep -E "\[ruby-\]" | tail -n 1 | sed -E "s/\[ruby-\](.*?)\[.*/\1/")

rvm install $RUBY_VER
rvm --default use $RUBY_VER

# Install rails, passenger and nginx
sudo yum -y install nodejs npm
gem install rails passenger
rvmsudo passenger-install-nginx-module
# wget -O nginx http://bit.ly/8XU8Vl
cd $INSTALLER_PATH
sudo chmod +x nginx
sudo cp nginx /etc/init.d
sudo /sbin/chkconfig nginx on

echo
echo "Finished!"
echo
echo "Installation directory: $INST_DIR"
ls $INST_DIR

while [$DELETE != 'y' && $DELETE != 'n' && $DELETE != 'Y' && $DELETE != 'N']
do
  echo "You won't probably need it anymore, would you like to delete it? (y/n)"
  read DELETE
done

if [ $DELETE = 'y' || $DELETE = 'Y']
then
  rm -r $INST_DIR
  echo "Alright, deleted. Have a nice developing day!"
else
  echo "Alright, keep it then. Have a nice developing day!"
fi
