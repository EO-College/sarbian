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
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPTDIR
declare -r BUILDDIR="$SCRIPTDIR/../sarbian-xfce"

##
# install live-build scripts
echo "[SARBIAN-BUILD] Installing live-build..."
apt update
apt install --assume-yes live-build

##
# run cleanup and collect-packages (not as root!)
echo "[SARBIAN-BUILD] Cleaning directories for package builds..."
sudo -u "$SUDO_USER" "$SCRIPTDIR/cleanup.sh"
echo "[SARBIAN-BUILD] Building packages..."
sudo -u "$SUDO_USER" "$SCRIPTDIR/collect-packages.sh"

##
# change into live image build tree, clean and build
echo "[SARBIAN-BUILD] Cleaning build directory..."
cd "$BUILDDIR"
lb clean
echo "[SARBIAN-BUILD] Building SARbian ISO image..."
lb build

echo "[SARBIAN-BUILD] Calculating checksums..."
for chksum in sha256sum sha384sum sha512sum; do
    "$chksum" "$BUILDDIR/live-image-amd64.hybrid.iso" > "$BUILDDIR/live-image-amd64.hybrid.iso.$chksum"
done

echo "[SARBIAN-BUILD] Finished building SARbian."
