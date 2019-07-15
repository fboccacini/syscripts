#!/bin/bash
set -e

PROJECT_PATH=/var/rails/

get_info() {

  echo "Project name:"
  read PROJECT_NAME

  echo "Project path (project name will be added):  $PROJECT_PATH"
  read PROJECT_PATH

  echo "DB production url:"
  read DB_PRO_URL
  echo

  echo "DB development url:"
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

# Get informations
get_info

while [ $CONFIRM != 'y' ]
do

  echo
  echo "Project name: $PROJECT_NAME"
  echo "Project path: $PROJECT_PATH/$PROJECT_NAME"
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
  then
    get_info
  else
    echo "Confirm with 'y' or 'n'. 'quit' to exit."
  fi

done

echo "Let's start the project"
cd $PROJECT_PATH
rails g $PROJECT_NAME

# TODO - params substitution in rails config files
# echo "create database $(echo $PROJECT_NAME)_pro; create database $(echo $PROJECT_NAME)_dev; create database $(echo $PROJECT_NAME)_test; create user $(echo $DB_PRO_USER)@localhost identified by '$(echo $DB_PRO_PASS)'; create user $(echo $DB_DEV_USER)@localhost identified by '$(echo $DB_DEV_PASS)'; grant all privileges on $(echo $PROJECT_NAME)_pro.* to $(echo $DB_PRO_USER)@localhost; grant all privileges on $(echo $PROJECT_NAME)_dev.* to $(echo $DB_DEV_USER)@localhost;" | mysql -u root -p
