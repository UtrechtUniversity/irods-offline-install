#!/bin/bash

set -e
set -o pipefail
set -u

source ./local-repo.env

export DEBIAN_FRONTEND=noninteractive

OS=$(uname -s)
if [ "$OS" == "Darwin" ]
then BASEPATH=$(cd "$(dirname "$0")"; pwd)
elif [ "$OS" == "Linux" ]
then SCRIPT=$(readlink -f "$0")
     BASEPATH=$(dirname "$SCRIPT")
else echo "Unable to determine script base path for OS $OS."
fi

if ! command -v vagrant
  then echo "Error: Vagrant has not been installed." && exit 1
fi

if [ "$(vagrant --version | awk '{print $2}' | cut -d '.' -f 2)" != "2" ]
  then echo "Error: wrong Vagrant version. Version 2.x is required" && exit 1
fi

for plugin in vagrant-scp vagrant-env
do
  if vagrant plugin list | grep -q vagrant-scp
    then true
    else echo "Error: Vagrant $plugin plugin has not been installed." && exit 1
  fi
done

echo "Copying scripts to Vagrant directories ..."
cp "$BASEPATH/local-repo.env" "$BASEPATH/vagrant/.env"
cp "$BASEPATH/local-repo.env" "$BASEPATH/test-offline-install/.env"
cp "$BASEPATH/local-repo.env" "$BASEPATH/offline-install"

cd "$BASEPATH/vagrant"

echo "Checking if VM has already been provisioned ..."
if vagrant status vm >& /dev/null
  then echo
       echo "It seems that the VM has already been provisioned. Press enter to delete it (or ctrl-c to abort script)."
       read -r
       echo "Removing VM ..."
       vagrant destroy -f vm
  else echo "OK: VM has not been provisioned yet."
fi

echo "Updating Vagrant Box to latest version"
vagrant box update

echo "Starting VM for collection of relevant package files ..."
vagrant up

echo "Copying offline repository archive ..."
vagrant scp vm:/offline_repo.tar.gz "$BASEPATH/offline-install"

echo "Script finished. Please copy the contents of $BASEPATH/offline-install to mobile media for installation on another computer."
