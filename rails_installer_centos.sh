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
  echo "  -b: install db (default)" 1>&2;
  echo "  --db-type <mariadb|postgresql>: choose db type, assumes -b" 1>&2;
  echo "  -g: install git (default)" 1>&2;
  echo "  --install-git <y|n>: choose whether or not to install git" 1>&2;

  exit 1;
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
            DB='y'
            DB_TYPE='1'
            ;;
        assume-yes)
            UPDATE='y'
            DELETE='y'
            GIT='y'
            ;;
        b)
            DB='y'
            ;;
        db-type)
            DB='y'
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

# Set user (get to sudo alread -sy so it won't ask later)
sudo echo "What user should execute the webserver? We'll create one if it doesn't exist."
read NEW_USER > /dev/null 2>&1

# Disable stop on error in case the id command fails
set +e
id -u $NEW_USER > /dev/null 2>&1

if [ $? -eq 0 ]
then
  # Re-enable stop on error
  set -e
  echo
  echo "Ok, we'll use $NEW_USER."
  echo
else
  # Re-enable stop on error
  set -e
  echo
  echo "Adding user: $NEW_USER.."

  NEW_PASSWD_RETYPED='ssdasd'

  while [[ "$NEW_PASSWD" != "$NEW_PASSWD_RETYPED" ]]
  do
    echo "Password:"
    read -s NEW_PASSWD

    echo "Retype it:"
    read -s NEW_PASSWD_RETYPED

  done

  sudo useradd -m $NEW_USER
  echo $NEW_PASSWD | sudo passwd $NEW_USER --stdin
  echo "User $NEW_USER created."
  echo
fi


# Perform system update
while [[ $UPDATE != "y" ]] && [[ $UPDATE != "n" ]] && [[ $UPDATE != "Y" ]] && [[ $UPDATE != "N" ]] && [[ $UPDATE != "" ]]
do
  echo "Proceed with system update? (Y/n)"
  read -s UPDATE
done

if [[ $UPDATE = "y" ]] || [[ $UPDATE = "Y" ]] || [[ $UPDATE = "" ]]
then

  # Update the system
  bash ./rails_installer/update.sh

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
sudo yum -y install openssl openssl-devel subversion curl curl-devel gcc-c++ patch read -sline read -sline-devel zlib zlib-devel libyaml-devel libffi-devel  make bzip2 autoconf automake libtool bison sqlite-devel libxml2 libxml2-devel libxslt libxslt-devel libtool
echo




# Get installer path for later use
INSTALLER_PATH=$(pwd)

while [[ $GIT != 'y' ]] && [[ $GIT != 'n' ]] && [[ $GIT != 'Y' ]] && [[ $GIT != 'N' ]]
do
  echo "Would you like to install git? (Y/n)"
  read -s GIT
done

if [[ $GIT = 'y' ]] || [[ $GIT = 'Y' ]]
then

  # Install git
  bash ./rails_installer/git-install.sh

else
  echo "Git installation skipped."
  echo
fi



# Create a folder to contain all needed packages
mkdir -p installation
sudo chmod 777 installation

echo

cd installation
INST_DIR=$(pwd)

while [[ $DB != 'y' ]] && [[ $DB != 'n' ]] && [[ $DB != 'Y' ]] && [[ $DB != 'N' ]]
do
  echo "Would you like to install a local db server? (y/n)"
  read -s DB
done

if [[ $DB = 'y' ]] || [[ $DB = 'Y' ]]
then
  # DB choice
  while [[ $DB_TYPE != '1' ]] && [[ $DB_TYPE != '2' ]]
  do
    echo "Which DB server would you like to install?"
    echo "    1 - MariaDB"
    echo "    2 - Postresql"
    read -s DB_TYPE
  done


  case "${DB_TYPE}" in

  2)

    # Install Postgresql server
    bash $INSTALLER_PATH/rails_installer/postgres-install.sh
    ;;

  *)

    # Install MariaDB server
    bash $INSTALLER_PATH/rails_installer/mariadb-install.sh
    ;;

  esac

fi

if [[ $NEW_USER != $(whoami)]]
then

# Change user to install gem in it's path
echo "Becoming $NEW_USER to install packages:"

# Install RVM and Ruby
sudo -iu $NEW_USER bash $INSTALLER_PATH/rails_installer/rvm-ruby-install.sh

# Install rails, passenger and nginx
sudo -iu $NEW_USER bash $INSTALLER_PATH/rails_installer/rails-passenger-nginx.sh

cd $INSTALLER_PATH
echo
echo "Finished!"
echo
echo "Installation directory: $INST_DIR"
ls $INST_DIR

while [$DELETE != 'y' && $DELETE != 'n' && $DELETE != 'Y' && $DELETE != 'N']
do
  echo "You won't probably need it anymore, would you like to delete it? (y/n)"
  read -s DELETE
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
  read -s CONFIG
done

if [ $CONFIG = 'y' || $CONFIG = 'Y']
then
  sudo -iu $NEW_USER bash $INSTALLER_PATH/rails_installer/configure-rails.sh
  echo "Ok, all done. Have a nice developing day!"
else
  echo "Ok, don't forget to configure it manually then. Have a nice developing day!"
fi
!
