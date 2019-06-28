#!/bin/bash

# MIT License
#
# Copyright (c) 2019 fabio boccacini <fboccacini@gmail.com> ver. 0.1
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


usage() {
  echo "Usage: $0 [-c|--config-only] [-y|--assume-yes] [-u|--system-update <y|n>] [-d|--delete-install-folder <y|n>] [-g|--install-git <y|n>] [-db <mariadb|postgresql>]" 1>&2;
  echo "  -c --config-only: skips installation and goes straight to rails db configuration."
  echo "  -y --assume-yes: non-interactive mode" 1>&2;
  echo "  -u: performs system update at the beginning (default)" 1>&2;
  echo "  --system-update <y|n>: choose whether or not to perform system update" 1>&2;
  echo "  -d: remove installation folder at the end" 1>&2;
  echo "  --delete-install-folder <y|n>: choose whether or not to remove installation folder at the end" 1>&2;
  echo "  -db <mariadb|postgresql>: choose db type" 1>&2;
  echo "  -g: install git (default)" 1>&2;
  echo "  --install-git <y|n>: choose whether or not to install git" 1>&2;

  exit 1;
}

get_info() {
  echo "Project name:"
  read PROJECT_NAME

  echo "User that will execute the server:"
  read NEW_USER
  echo "Password:"
  read NEW_PASSWD
  echo

  echo "DB production url:"
  read DB_PRO_URL
  echo

  echo "DB developemnt url:"
  read DB_DEV_URL
  echo

  echo "DB test url:"
  read DB_TEST_URL
  echo

  echo "DB production user:"
  read DB_PRO_USER
  echo "Password:"
  read DB_PRO_PASS
  echo

  echo "DB development user:"
  read DB_DEV_USER
  echo "Password:"
  read DB_DEV_PASS
  echo

  echo "DB test user:"
  read DB_TEST_USER
  echo "Password:"
  read DB_TEST_PASS
  echo
}

rails_configuration() {

  # Get informations
  get_info()

  while [ $CONFIRM != 'y' ]
  do

    echo
    echo "Project name: $PROJECT_NAME"
    echo "User: $NEW_USER"
    echo "Password: $PASSWORD"
    echo "DB production url: $DB_PRO_URL"
    echo "DB development url: $DB_DEV_URL"
    echo "DB production user: $DB_PRODUCTION_USER"
    echo "DB production password: $DB_PRO_PASSWORD"
    echo "DB development user: $DB_DEV_USER"
    echo "DB develpment password: $DB_DEV_PASSWORD"
    echo "DB test user: $DB_TEST_USER"
    echo "DB test password: $DB_TEST_PASSWORD"
    echo
    echo "Are the informations correct? (y/n/quit)"

    read CONFIRM

    if [ $CONFIRM = 'quit' ]
    then
      exit 0
    elif [ $CONFIRM = 'n']
      get_info()
    fi

  done

  # TODO - params substitution in rails config files

}

set -e

echo "+-----------------------------------------------------------------+"
echo "| Ruby-on-Rails interactive installer                             |"
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

# Get options
while getopts ":y:assume-yes:db:git" o; do
    case "${o}" in
        y)
            UPDATE='y'
            DELETE='y'
            GIT='y'
            ;;
        assume-yes)
            UPDATE='y'
            DELETE='y'
            GIT='y'
            ;;
        db)
            CHOICE=${OPTARG}
            case $CHOICE in
                mariadb)
                  DB_TYPE='1'
                  ;;
                postgresql)
                  DB_TYPE='2'
                  ;;
                *)
                  usage
                  ;;
            esac
            ;;
        g)
            GIT='y'
            ;;
        install-git)
            GIT=${OPTARG}
            (($GIT = 'y' || $GIT = 'Y' || $GIT = 'n' || $GIT = 'N')) || usage
            ;;
        u)
            UPDATE='y'
            ;;
        system-update)
            UPDATE=${OPTARG}
            (($UPDATE = 'y' || $UPDATE = 'Y' || $UPDATE = 'n' || $UPDATE = 'N')) || usage
            ;;
        d)
            DELETE='y'
            ;;
        delete-install-directory)
            DELETE=${OPTARG}
            (($DELETE = 'y' || $DELETE = 'Y' || $DELETE = 'n' || $DELETE = 'N')) || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${p}" ]; then
    usage
fi

# Perform system update
while [$UPDATE != 'y' && $UPDATE != 'n' && $UPDATE != 'Y' && $UPDATE != 'N']
do
  echo "First things first, proceed with system update? (y/n)"
  read UPDATE
done

if [ $UPDATE = 'y' || $UPDATE = 'Y']
then

  echo "Upgrading system.."
  sudo yum -y upgrade
  echo

else
  echo "System update skipped."
  echo
fi

echo "Enabling EPEL.."
echo
# Enable epel
sudo yum -y --enablerepo=extras install epel-release
echo

echo "Installing dependencies.."
sudo yum -y install openssl openssl-devel subversion curl curl-devel gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel  make bzip2 autoconf automake libtool bison sqlite-devel libxml2 libxml2-devel libxslt libxslt-devel libtool
echo


# Add user
id -u NEW_USER > /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo
  echo "User $NEW_USER exists already."
  echo
else
  echo
  echo "Adding user: $NEW_USER.."
  sudo useradd -m -p $NEW_PASSWD $NEW_USER
  echo "User $NEW_USER created."
  echo
fi

# Get installer path for later use
INSTALLER_PATH=$(pwd)

while [$GIT != 'y' && $GIT != 'n' && $GIT != 'Y' && $GIT != 'N']
do
  echo "Would you like to install git? (y/n)"
  read GIT
done

if [ $GIT = 'y' || $GIT= 'Y']
then
  # Install git
  echo "Installing Git.."
  sudo yum -y install git git-core
  echo

else
  echo "Git installation skipped."
  echo
fi


# DB choice
while [ $DB_TYPE != '1' && $DB_TYPE != '2']
do
  echo "Which DB server would you like to install?"
  echo "    1 - MariaDB"
  echo "    2 - Postresql"
  read DB_TYPE
done

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
  echo "Installing Postgresql server.."
  sudo yum -y install postgresql postgresql-devel postgresql-server postgresql-libs postgresql-contrib

  $POSTGRES_EXE=$( ls /etc/init.d/postgresql* )

  sudo /etc/init.d/$POSTGRES_EXE initdb
  sudo /etc/init.d/$POSTGRES_EXE start
  sudo /etc/init.d/$POSTGRES_EXE chkconfig --levels 235 $POSTGRES_EXE on

  POSTGRES_PASS_RETYPED='ssdasd'
  while [ $POSTGRES_PASS != $POSTGRES_PASS_RETYPED ]
  do
    echo "Set postgres password:"
    read POSTGRES_PASS
    echo "Retype it:"
    read POSTGRES_PASS_RETYPED
    echo
  done
  sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$POSTGRES_PASSWORD';"


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

# Change user
echo "Becoming $NEW_USER to install gems:"
echo

# Create a folder to contain all needed packages
mkdir -p installation
sudo chmod 777 installation

cd installation
INST_DIR=$(pwd)

su $NEW_USER
cd $INST_DIR

gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -L https://get.rvm.io | sudo bash -s stable --ruby
source /etc/profile.d/rvm.sh



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
  echo "Alright, folder deleted."
else
  echo "Alright, deletion skipped."
fi

while [$CONFIG != 'y' && $CONFIG != 'n' && $CONFIG != 'Y' && $CONFIG != 'N']
do
  echo "Finally, do you want configure rails as well? (y/n)"
  read CONFIG
done

if [ $CONFIG = 'y' || $CONFIG = 'Y']
then
  rails_configuration()
  echo "Ok, all done. Have a nice developing day!"
else
  echo "Ok, don't forget to configure it manually then. Have a nice developing day!"
fi
