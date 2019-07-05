#!/bin/bash

echo "test user password:"
read PASS
sudo useradd test
echo "user test added."
echo
echo $PASS | sudo passwd test --stdin
su - test <<!
$(echo $PASS)
echo
echo
whoami
pwd
ls -lah
echo
!

sudo userdel -r test
echo "test user removed."
