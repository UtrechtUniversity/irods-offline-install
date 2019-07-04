#!/bin/sh
#
# This script removes the regular apt repositories on an Ubuntu server in order
# to test whether an offline install succeeds. This script should only be used on test VMs
set -e

echo "Removing all regular apt repositories ..."
sudo rm -f /etc/apt/sources.list.d/*
sudo echo > /etc/apt/sources.list
sudo apt-get update

echo "Regular apt repositories have been removed."
