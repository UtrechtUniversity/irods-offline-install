#!/bin/bash

set -e
set -u

REPOFILE=${1:-/tmp/offline_repo.tar.gz}

SETTINGSFILE=${2:-./local-repo.env}

if [ -f "$SETTINGSFILE" ]
then source "$SETTINGSFILE"
else echo "Error: settings file $SETTINGSFILE not found." && exit 1
fi

LOCALREPODIR=/irodsrepo

echo "Extracting local repository ..."
sudo mkdir -p "$LOCALREPODIR"
cd "$LOCALREPODIR"
sudo tar xvfz $REPOFILE

echo "Registering local repository ..."
echo "deb [trusted=yes] file:$LOCALREPODIR ./" | sudo tee /etc/apt/sources.list.d/irods-local.list
sudo apt-get update

echo "Installing packages ..."
sudo apt-get -y install $APT_PACKAGES

echo "Script finished."
