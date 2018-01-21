#!/bin/bash

# script to build the sarbian image 

# abort on error
set -e

##
# abort, if we are not root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Script must be run with superuser privileges." >> /dev/stderr
    exit 1
fi

##
# define important directories
declare -r SCRIPTDIR="$(readlink -f "$(dirname "$0")")"

##
# install live build scripts
apt update
apt install --assume-yes live-build

##
# run cleanup and collect-packages (not as root!)
sudo -u $SUDO_USER "$SCRIPTDIR/cleanup.sh"
sudo -u $SUDO_USER "$SCRIPTDIR/collect-packages.sh"

##
# change into live image build tree, clean and build
cd "$SCRIPTDIR/../sarbian-xfce/"
lb clean
lb build
