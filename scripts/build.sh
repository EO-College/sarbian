#!/bin/bash
#
# build.sh - build the SARbian image
#
# Copyright (C) 2017-2018 Felix Cremer, Felix Glaser
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

##
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
# install live-build scripts
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
