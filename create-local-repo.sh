#!/bin/bash

set -e
set -o pipefail
set -u

export DEBIAN_FRONTEND=noninteractive

ARCHIVE_FILE=/offline_repo.tar.gz
ARCHIVE_DIRECTORY=/var/cache/apt/archives
TEMPDIR=/tmp/debfiles

if [ -f ./local-repo.env ]
then source ./local-repo.env
elif [ -f /tmp/local-repo.env ]
then source /tmp/local-repo.env
else echo "Error: local-repo.env file not found." && exit 1
fi

echo "Downloading and installing iRODS repository signing key ..."
wget -qO - "$APT_IRODS_REPO_SIGNING_KEY_LOC" | sudo apt-key add -

echo "Adding iRODS repository ..."
cat << ENDAPTREPO | sudo tee /etc/apt/sources.list.d/irods.list
deb [arch=${APT_IRODS_REPO_ARCHITECTURE}] $APT_IRODS_REPO_URL $APT_IRODS_REPO_DISTRIBUTION $APT_IRODS_REPO_COMPONENT
ENDAPTREPO
sudo apt-get update

echo "Installing package dependencies of create-local-repo script ..."
sudo apt-get install -y dpkg-dev

for package in $APT_PACKAGES
do echo "Downloading package $package and its dependencies"
   sudo apt-get -dy install "$package"
done

echo "Copying apt packages to temporary directory ..."
mkdir -p "$TEMPDIR"
cp ${ARCHIVE_DIRECTORY}/*.deb "$TEMPDIR"

echo "Indexing apt packages ..."
cd "$TEMPDIR"
dpkg-scanpackages . | gzip -9c > Packages.gz

echo "Archiving local repository ..."
sudo tar cvfz "$ARCHIVE_FILE" ./*.deb Packages.gz

echo "Script finished. Local repository archive file is $ARCHIVE_FILE."
