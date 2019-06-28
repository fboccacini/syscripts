# syscripts
Sysadmin useful scripts and configuration files

-- Rails Centos Installer

This is an interactive bash script to install Ruby-on-Rails with RVM, MariaDB or Postgresql, Passenger and Nginx on Centos Linux.
It also helps configure and create users.

- Usage:

bash rails_installer_centos.sh [-c|--config-only] [-y|--assume-yes] [-u|--system-update <y|n>] [-d|--delete-install-folder <y|n>] [-g|--install-git <y|n>] [-db <mariadb|postgresql>]

Options:
  -c --config-only: skips installation and goes straight to rails configuration.
  -y --assume-yes: non-interactive mode
  -u: performs system update at the beginning (default)
  --system-update <y|n>: choose whether or not to perform system update
  -d: remove installation folder at the end
  --delete-install-folder <y|n>: choose whether or not to remove installation folder at the end
  -db <mariadb|postgresql>: choose db type
  -g: install git (default)
  --install-git <y|n>: choose whether or not to install git


- Versions:

  0.1: Install base package dependencies, a choice between MariaDB and Postgresql, optionally git.
