# irods-offline-install

This is a set of scripts for creating a local repository of iRODS packages and their dependencies.
It can be used for installing iRODS on offline computers, for example using a USB stick.

The basic idea is that you first run a script to create an archive file with
a local repository of iRODS packages on an Internet-connected system.
The archived local repository can then be copied to one or more offline systems in order
to install the iRODS packages without access to Internet.

This assumes that the Internet-connected system is in the same state as the offline system(s).
Differences in installed packages between the online system and the offline system(s) might
result in an incomplete local repository, or other issues with installing the packages on the
offline systems.

The scripts have only been tested on Ubuntu 18.04 LTS.

# Prerequisites

In order to test the scripts locally using Vagrant, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads), as well as [Vagrant 2.x](https://www.vagrantup.com/downloads.html) with these plugins:
- SCP plugin: _vagrant plugin install vagrant-scp_
- Env plugin: _vagrant plugin install vagrant-env_

# Usage

The default configuration installs the latest version of iRODS, as well as the Postgresql database plugin, Python rule engine, and the
Postgresql database. If you'd like to customize the list of packages to be installed, adjust the APT_PACKAGES variable in _local-repo.env_

First create the archive of the local repository on an Internet-connected system:
- Copy the _local-repo.env_ file and the _create-local-repo.sh_ script to the online system.
- If the system does not have a fresh OS install, you might want to check for any irrelevant .deb files in /var/cache/apt/archives that have been downloaded previously. Remove them, so they don't end up in the local repository.
- Run the _create-local.repo.sh_ script with the location of the _local-repo.env_ file as an argument, e.g. _./create-local-repo.sh /home/user/local-repo.env_. The argument can be omitted, if the _local-repo.env_ file is in the current working directory.
- The script should create an _offline_repo.tar.gz_ file in the root directory.

Now install the packages on an offline system:
- Copy the _offline_repo.tar.gz_ file from the online system to the offline system, as well as the _local-repo.env_ file.
- Copy the _offline-install/install-offline.sh_ script from the repository to the offline system.
- Now install the packages from the local repository: _./install-offline.sh offline_repo.tar.gz local-repo.env_. Adjust the location of the repository tarball and the environment file if they aren't in the working directory.
- In order to use iRODS, it is necessary to initialize the database and run the setup script. Please consult the _Installing iRODS_ section of the [iRODS beginner training](https://github.com/irods/irods_training/blob/master/beginner/irods_beginner_training_2019.pdf) for details.

# Testing the scripts using Vagrant

- If you'd like to customize the packages to be installed, adjust the the APT_PACKAGES variable in _local-repo.env_.
- Run _./prepare-offline-repo.sh_ . This script creates a VM and downloads the required iRODS packages, as well as their dependencies. It copies a tarball containing a local apt repository with the packages to the _offline-install_ directory.
- Start the test VM: _cd test-offline-install && vagrant destroy -f && vagrant up_. Vagrant automatically configures the local iRODS repository and installs the iRODS packages.
- You can log in on the test VM using _vagrant ssh_ to check that the packages have been installed correctly. In order to use iRODS, it is necessary to initialize the database and run the setup script. Please consult the _Installing iRODS_ section of the [iRODS beginner training](https://github.com/irods/irods_training/blob/master/beginner/irods_beginner_training_2019.pdf) for details.

# License

MIT License - see LICENSE file

# Author

Sietse Snel, Utrecht University

# Acknowledgements

Thanks to Tony Anderson, Rob van Schip and Terrell Russell for their feedback on earlier
versions of these scripts.
