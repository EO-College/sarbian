#!/bin/bash
#
# download-snap.sh - download script for ESA SNAP Sentinel Toolbox installer
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
# define important directories
declare -r SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
declare -r CACHEDIR="${SCRIPTDIR}/cache"
declare -r BUILDDIR="${SCRIPTDIR}/build"
declare -r PKGDIR="${SCRIPTDIR}/pkg"

##
# Simple wrapper around sha256sum. Returns 0 if sha256 and file match
# $1: file to check
# $2: (expected) sha256 hash of the file
function checkFile {
    sha256sum "$1" | cut -d' ' -f1 | grep -o "$2" > /dev/null
    return $?
}

###############################################################################
# define snap version here
# make necessary adjustments when using a newer versions
declare -r appname="esa-snap"
declare -r appver="6.0"
declare -r file="${appname}_sentinel_unix_${appver/./_}.sh"
declare -r url="http://step.esa.int/downloads/${appver}/installers/${file}"
declare -r sha256sum="3e92651f68bd4ea2fd523bd1b31ed8c31347eba73dd4d25fa4791ea2f748ef18"

# SNAP installer currently corrupts the icon for SNAP, so we manually replace it
declare -r icon_file="SNAP_Icon_48.png"
declare -r icon_url="https://raw.githubusercontent.com/senbox-org/snap-installer/${appver}.0/images/${icon_file}"
declare -r icon_sha256sum="0a887f0d8a53ec17036e0149710b44040ca4b5dc7dbdc342b50cc24d5e97670b"

# install curl
echo ">>> Installing prerequisites..."
sudo apt update && sudo apt install --assume-yes curl

###############################################################################
# download installer
echo ">>> Downloading installer, if required"
mkdir -p "$CACHEDIR"
if [[ -e "$CACHEDIR/$file" ]] && $(checkFile "$CACHEDIR/$file" "$sha256sum"); then
    echo ">>> No download necessary, using cached version."
else
    curl -L "$url" -o "$CACHEDIR/$file"

    echo -n ">>> Verifying checksum... "
    if ! $(checkFile "$CACHEDIR/$file" "$sha256sum"); then
        echo "FAIL"
        echo ">>> Downloaded SNAP installer '$CACHEDIR/$file' does not match sha256sum '$sha256sum'." >> /dev/stderr
        echo ">>> Aborting." >> /dev/stderr
        exit 1
    fi
    echo "OK"

    chmod 755 "$CACHEDIR/$file"
    echo ">>> SNAP installer has been downloaded."
fi

###############################################################################
# download SNAP icon
echo ">>> Downloading SNAP icon, if required"
if [[ -e "$CACHEDIR/$icon_file" ]] && $(checkFile "$CACHEDIR/$icon_file" "$icon_sha256sum"); then
    echo ">>> No download necessary, using cached version."
else
    curl -L "$icon_url" -o "$CACHEDIR/$icon_file"

    echo -n ">>> Verifying checksum... "
    if ! $(checkFile "$CACHEDIR/$icon_file" "$icon_sha256sum"); then
        echo "FAIL"
        echo ">>> Downloaded SNAP icon '$CACHEDIR/$icon_file' does not match sha256sum '$icon_sha256sum'." >> /dev/stderr
        echo ">>> Aborting." >> /dev/stderr
        exit 1
    fi
    echo "OK"

    echo ">>> SNAP icon has been downloaded."
fi

###############################################################################
# copy files into live build environment
declare -r INCLUDES_CHROOT="$(readlink -f "$SCRIPTDIR/..")/sarbian-xfce/config/includes.chroot/usr/local"
mkdir -p "$INCLUDES_CHROOT/bin" "$INCLUDES_CHROOT/share"
echo ">>> Copying SNAP installer and icon into '$INCLUDES_CHROOT'..."
cp -v "$CACHEDIR/$file" "$INCLUDES_CHROOT/bin"
cp -v "$CACHEDIR/$icon_file" "$INCLUDES_CHROOT/share/"

echo ">>> SNAP installer and icon have been placed in live build environment."
