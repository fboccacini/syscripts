#!/bin/bash

if [ -z "$1" ]
then
  NEW_USER=$(whoami)
else
  NEW_USER=$1
fi

echo
echo "Installing RVM as $NEW_USER.."
echo

grep -q rvm /etc/group

if [ $? -ne 0 ]
then
  echo "Adding rvm group."
  sudo groupadd rvm
  echo
fi

set -e

sudo usermod -a -G rvm root
sudo usermod -a -G rvm $NEW_USER
sudo usermod -a -G wheel $NEW_USER
echo
curl -sSL https://rvm.io/mpapis.asc | sudo gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | sudo gpg2 --import -
echo
# gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -L https://get.rvm.io | sudo bash -s stable --ruby
# curl -L https://get.rvm.io | sudo bash -s stable
echo
echo "Setting up rvm envs: source /etc/profile.d/rvm.sh"
source /etc/profile.d/rvm.sh
echo
# Get latest ruby version and install it -- DEPRECATED, it gets the unstable version that breaks on rubies installation
# RUBY_VER=$(rvm list known | grep -E "\[ruby-\]" | tail -n 1 | sed -E "s/\[ruby-\](.*?)\[.*/\1/")
#
# rvm install $RUBY_VER
# rvm --default use $RUBY_VER
echo
rvm list
echo
