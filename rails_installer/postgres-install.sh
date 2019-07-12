#!/bin/bash
set -e

echo "Installing Postgresql server.."
sudo yum -y install postgresql postgresql-devel postgresql-server postgresql-libs postgresql-contrib

# Initial setup
echo "Initial setup"
sudo postgresql-setup initdb
sudo systemctl enable Postgresql
sudo service postgresql start

sudo -u postgres psql -t -P format=unaligned -c 'show hba_file';

# Set up postgres user
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

# Set up hba file
