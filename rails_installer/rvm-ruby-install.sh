#!/bin/bash
set -e

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



# Get latest ruby version and install it
RUBY_VER=$(rvm list known | grep -E "\[ruby-\]" | tail -n 1 | sed -E "s/\[ruby-\](.*?)\[.*/\1/")

rvm install $RUBY_VER
rvm --default use $RUBY_VER
