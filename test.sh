#!/bin/bash

echo "test user password:"
read PASS
sudo useradd test
echo "user test added."
echo
echo $PASS | sudo passwd test --stdin


# export PASS=asdasdasdasdasd
bash test2.sh $PASS

# read
PTH=$(pwd)
sudo -iu test bash $PTH/test2.sh $PASS

sudo userdel -r test
echo "test user removed."
