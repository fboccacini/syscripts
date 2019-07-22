#!/bin/bash
set -e

# Get starting path to get back after execution
STARTING_PATH=$(pwd)

# Get installer path to call specific scripts
ABS_PATH=$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")
INSTALLER_PATH=$(dirname $ABS_PATH)

GIT_USER=''
CONFIRM='x'

# Defaults
RAILS_USER=$(whoami)
PROJECT_NAME=$RAILS_USER
DB_TYPE=$1
DB_PRO_URL=localhost

get_info() {

  # Initialize options
  GIT='x'
  NEW='x'
  GET_ENVIRON='x'
  GIT='x'

  # General informations
  echo
  echo -n "Project name: $PROJECT_NAME "
  read GET_PROJECT_NAME
  if [ -n "$GET_PROJECT_NAME" ]
  then
    PROJECT_NAME=$GET_PROJECT_NAME
  fi
  # Avoid spaces
  PROJECT_NAME=$(echo $PROJECT_NAME | sed 's/ /_/g' )

  if [ -z "$PROJECT_PATH" ]
  then
    PROJECT_PATH=/var/rails/$PROJECT_NAME
  fi
  echo
  echo -n "Project codebase path:  $PROJECT_PATH "
  read GET_PROJECT_PATH
  if [ -n "$GET_PROJECT_PATH" ]
  then
    PROJECT_PATH=$GET_PROJECT_PATH
  fi

  # Git informations
  echo
  echo -n "Is there a Git repository for this project? [Y/n] "

  while [[ $GIT != 'y' ]] && [[ $GIT != 'n' ]] && [[ $GIT != 'Y' ]] && [[ $GIT != 'N' ]] && [[ $GIT != '' ]]
  do
    read GIT
  done

  if [[ $GIT = 'y' ]] || [[ $GIT = 'Y' ]] || [ -z $GIT ]
  then

    echo
    echo -n "Git username: $GIT_USER "
    read GET_GIT_USER
    if [ -n "$GET_GIT_USER" ]
    then
      GIT_USER=$GET_GIT_USER
    fi

    if [ -n "$GIT_USER" ]
    then
      if [ -z "$GIT_REPOSITORY" ]; then GIT_REPOSITORY="https://github.com/$GIT_USER/$PROJECT_NAME.git"; fi
      echo
      echo -n "Git repository url: $GIT_REPOSITORY (type '-' to unset) "
      read GET_GIT_REPOSITORY

      if [ -n "$GET_GIT_REPOSITORY" ]
      then
        if [[ $GET_GIT_REPOSITORY == '-' ]]
        then
          GIT_REPOSITORY=''
          echo "Git configuration skipped."
        else
          GIT_REPOSITORY=$GET_GIT_REPOSITORY
        fi
      fi
    else
      GIT_REPOSITORY=''
      echo "Git configuration skipped."
    fi

    if [ -n "$GIT_REPOSITORY" ]
    then
      echo
      echo -n "Is it a new project or you just need to clone the repository? [Y/n] "
    else
      NEW='y'
    fi
    while [ -n "$GIT_REPOSITORY" ] && [[ $NEW != 'y' ]] && [[ $NEW != 'n' ]] && [[ $NEW != 'Y' ]] && [[ $NEW != 'N' ]] && [[ $NEW != '' ]]
    do
      read NEW
    done
  else
    GIT_REPOSITORY=''
    NEW='y'
    echo "Git configuration skipped."
  fi

  if [[ $NEW == 'Y' ]] || [[ $NEW == 'y' ]] || [ -z "$NEW" ] || [ -z $GIT_REPOSITORY ]
  then

    NEW='y'

    # Production informations
    echo
    echo -n "Production DB url: $DB_PRO_URL "
    read GET_DB_PRO_URL
    if [ -n "$GET_DB_PRO_URL" ]
    then
      DB_PRO_URL=$GET_DB_PRO_URL
    fi

    if [ -z "$DB_PRO_DB" ]
    then
      DB_PRO_DB="$(echo $PROJECT_NAME)_production"
    fi
    echo
    echo -n "Production DB name: $DB_PRO_DB "
    read GET_DB_PRO_DB
    if [ -n "$GET_DB_PRO_DB" ]
    then
      DB_PRO_DB=$GET_DB_PRO_DB
    fi

    if [ -z "$DB_PRO_USER" ]
    then
      DB_PRO_USER="$(echo $PROJECT_NAME)_pro"
    fi
    echo
    echo -n "Production DB user: $DB_PRO_USER "
    read GET_DB_PRO_USER
    if [ -n "$GET_DB_PRO_USER" ]
    then
      DB_PRO_USER=$GET_DB_PRO_USER
    fi

    # Test informations
    if [ -z "$DB_TEST_URL" ]
    then
      DB_TEST_URL=$DB_PRO_URL
    fi
    echo
    echo -n "Test DB url: $DB_TEST_URL "
    read GET_DB_TEST_URL
    if [ -n "$GET_DB_TEST_URL" ]
    then
      DB_TEST_URL=$GET_DB_TEST_URL
    fi

    if [ -z "$DB_TEST_DB" ]
    then
      DB_TEST_DB="$(echo $PROJECT_NAME)_test"
    fi
    echo
    echo -n "Test DB name: $DB_TEST_DB "
    read GET_DB_TEST_DB
    if [ -n "$GET_DB_TEST_DB" ]
    then
      DB_TEST_DB=$GET_DB_TEST_DB
    fi

    if [ -z "$DB_TEST_USER" ]
    then
      DB_TEST_USER="$(echo $PROJECT_NAME)_test"
    fi
    echo
    echo -n "Test DB user: $DB_TEST_USER "
    read GET_DB_TEST_USER
    if [ -n "$GET_DB_TEST_USER" ]
    then
      DB_TEST_USER=$GET_DB_TEST_USER
    fi

    # Development informations
    if [ -z "$DB_DEV_URL" ]
    then
      DB_DEV_URL=$DB_TEST_URL
    fi
    echo
    echo -n "Development DB url: $DB_DEV_URL "
    read GET_DB_DEV_URL
    if [ -n "$GET_DB_DEV_URL" ]
    then
      DB_DEV_URL=$GET_DB_DEV_URL
    fi

    if [ -z "$DB_DEV_DB" ]
    then
      DB_DEV_DB="$(echo $PROJECT_NAME)_development"
    fi
    echo
    echo -n "Development DB name: $DB_DEV_DB "
    read GET_DB_DEV_DB
    if [ -n "$GET_DB_DEV_DB" ]
    then
      DB_DEV_DB=$GET_DB_DEV_DB
    fi

    if [ -z "$DB_DEV_USER" ]
    then
      DB_DEV_USER="$(echo $PROJECT_NAME)_dev"
    fi
    echo
    echo -n "Development DB user: $DB_DEV_USER "
    read GET_DB_DEV_USER
    if [ -n "$GET_DB_DEV_USER" ]
    then
      DB_DEV_USER=$GET_DB_DEV_USER
    fi

  fi

  echo
  echo "Will this be a production or development server? "
  if [[ $ENVIRON == '1' ]]; then echo -n " --> "; else echo -n "     "; fi
  echo " 1 - Development"
  if [[ $ENVIRON == '2' ]]; then echo -n " --> "; else echo -n "     "; fi
  echo " 2 - Production"
  if [[ $ENVIRON == '3' ]]; then echo -n " --> "; else echo -n "     "; fi
  echo " 3 - Both"
  echo

  while ( [[ $GET_ENVIRON != '1' ]] && [[ $GET_ENVIRON != '2' ]] && [[ $GET_ENVIRON != '3' ]] && [[ $GET_ENVIRON != '' ]] ) || [ -z $ENVIRON ]
  do
    read GET_ENVIRON
    if [ -n "$GET_ENVIRON" ]
    then
      ENVIRON=$GET_ENVIRON
    fi
  done


}

configure_rails() {
  echo "Rails Configuration.."
}

# Get informations
get_info

while [[ $CONFIRM != 'y' ]]
do

  echo
  echo "Rails user: . . . . . . . .$RAILS_USER"
  echo "Project name: . . . . . . .$PROJECT_NAME"
  echo "Project path: . . . . . . .$PROJECT_PATH/$PROJECT_NAME"
  echo "--------------------------------------------------------------"
  echo
  echo "Git configuration:"
  if [ -n "$GIT_REPOSITORY" ]
  then
    echo "  Git user: . . . . . . .$GIT_USER"
    echo "  Git repository: . . . .$GIT_REPOSITORY"
  else
    echo "           NOT USED"
  fi
  echo
  echo "DB configuration: $NEW"
  if [[ $NEW == 'y' ]] || [[ $NEW == 'Y' ]]
  then
    echo "    DB type:. . . . . . . .$DB_TYPE"
    echo
    echo "    production url: . . . .$DB_PRO_URL"
    echo "    production DB:. . . . .$DB_PRO_DB"
    echo "    production user:. . . .$DB_PRO_USER"
    echo "    test url: . . . . . . .$DB_TEST_URL"
    echo "    test DB:. . . . . . . .$DB_TEST_DB"
    echo "    test user:. . . . . . .$DB_TEST_USER"
    echo "    development url:. . . .$DB_DEV_URL"
    echo "    development DB: . . . .$DB_DEV_DB"
    echo "    development user: . . .$DB_DEV_USER"
  else
    echo "           NOT USED"
  fi
  echo
  echo "Environment configuration:"
  case "$ENVIRON" in
    '1')
      echo "    Development server"
      ;;
    '2')
      echo "    Production server"
      ;;
    '3')
      echo "    Development and production server"
      ;;
    *)
      echo "Environment unconfigured."
      ;;
  esac
  echo
  echo -n "Are these informations correct? (y/n/quit) "

  read CONFIRM

  case "$CONFIRM" in
    quit|q)
      exit 0
      ;;
    n|N)
      get_info
      ;;
    y|Y)
      echo
      echo "Alright then."
      ;;
    *)
      echo "Confirm with 'y' or 'n'. 'quit' to exit."
      ;;
  esac

done

echo "Let's start the project!"
echo
$CODE_BASE_PATH=$(echo $PROJECT_PATH | sed 's/\(.*\)\/[a-z]*$/\1/')
$GIT_PATH=$(echo $GIT_REPOSITORY | sed 's/.*\/\([a-z]*\).git$/\1/')
echo $CODE_BASE_PATH
echo $GIT_PATH
exit
if [ -n "$GIT_REPOSITORY" ]
then
  # Check whether git is installed
  set +e

  git --version 2>/dev/null
  echo

  if [ $? -ne 0]
  then
    set -e
    echo -n "Git was not found on this system. Would you like to install it now? [Y/n] "
    while [[ $GIT != 'y' ]] && [[ $GIT != 'n' ]] && [[ $GIT != 'Y' ]] && [[ $GIT != 'N' ]] && [[ $GIT != '' ]]
    do
      read GIT
    done
    if [[ $GIT = 'y' ]] || [[ $GIT = 'Y' ]] || [ -z $GIT ]
    then
      # Install git
      bash $INSTALLER_PATH/scripts/git-install.sh
    else
      echo "Git is not installed."
      exit 1
    fi
  fi

  set -e

  echo "Creating Rails project.."
  echo
  cd $CODE_BASE_PATH
  rails new $PROJECT_NAME
  mv $PROJECT_NAME $(echo $PROJECT_PATH)_tmp

  echo "Cloning from Git repository ($GIT_REPOSITORY) in $CODE_BASE_PATH.."
  echo
  git clone $GIT_REPOSITORY

  echo "Moving project into repository.."
  echo

  echo "Configuring Git.."
  echo

  echo "Configuring Rails.."
  echo
  configure_rails

  echo "Initial commit and push"
  echo

  echo "Rails and Git configuration finished."
  echo
else
  echo "Creating Rails project.."
  echo
  cd $CODE_BASE_PATH
  rails new $PROJECT_NAME
  mv $PROJECT_NAME $PROJECT_PATH

  echo "Configuring Rails.."
  echo
  configure_rails

  echo "Rails configuration finished."
  echo
fi

echo "Nginx configuration.."
echo

# TODO - params substitution in rails config files
# echo "create database $(echo $PROJECT_NAME)_pro; create database $(echo $PROJECT_NAME)_dev; create database $(echo $PROJECT_NAME)_test; create user $(echo $DB_PRO_USER)@localhost identified by '$(echo $DB_PRO_PASS)'; create user $(echo $DB_DEV_USER)@localhost identified by '$(echo $DB_DEV_PASS)'; grant all privileges on $(echo $PROJECT_NAME)_pro.* to $(echo $DB_PRO_USER)@localhost; grant all privileges on $(echo $PROJECT_NAME)_dev.* to $(echo $DB_DEV_USER)@localhost;" | mysql -u root -p
