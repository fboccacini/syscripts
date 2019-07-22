#!/bin/bash

# Check whether postgres is already installed
hash postgres 2>/dev/null

if [ $? -eq 0 ]
then
  echo
  echo "Postgres is already installed. Skipping."
  echo
  exit 0
fi

set -e

echo "Installing Postgresql server.."
sudo yum -y install postgresql postgresql-devel postgresql-server postgresql-libs postgresql-contrib

# If in a vbox situation, add group to postgres too, to avoid changedir errors
if grep -q vboxsf /etc/group
then
    # Get starting groups, double sed'ing to cover single or multiple grouops
    GRPS=$(sudo groups postgres | sed 's/postgres : \([a-z ]* [a-z]*\) */\1/' | sed 's/postgres : \([a-z ]*\) */\1/' | sed 's/ /,/g')

    echo "Adding vboxsf group to postgres to avoid change directory errors."
    sudo usermod -a -G vboxsf postgres
    sudo groups postgres
fi

# Initial setup
echo "Initial setup"
sudo postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Get HBA file location
HBA_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file;')

# Set up postgres user
POSTGRES_PASS_RETYPED='ssdasd'
while [[ $POSTGRES_PASS != $POSTGRES_PASS_RETYPED ]]
do
  echo -n "Set postgres password:"
  read -s POSTGRES_PASS
  echo
  echo -n "Retype it:"
  read -s POSTGRES_PASS_RETYPED
  echo
done
sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$POSTGRES_PASSWORD';"
echo

# Set up hba file
echo "Setting up hba file: $HBA_FILE."
echo "It will be backed up in $HBA_FILE.bkp."
echo
sudo cp -a $HBA_FILE ${HBA_FILE}.bkp
sudo sed -i "s/\(.*all *[^a-z]*\)[a-z]*$/\1md5/I" $HBA_FILE

echo 'Done.'
echo

# Eventually remove vboxsf group from postgresql
if grep -q vboxsf /etc/group
then
    echo "Removing vboxsf group from postgres."
    sudo usermod -G $GRPS postgres
    sudo groups postgres
    echo
fi
