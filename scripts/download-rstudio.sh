#!/bin/bash
#
# download-rstudio.sh - download and install script for RStudio Desktop
#
# Copyright (C) 2017-2019 Felix Cremer, Felix Glaser
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
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPTDIR
declare -r PKGDIR="${SCRIPTDIR}/pkg"

##
# Simple wrapper around md5sum. Returns 0 if md5 and file match
# $1: file to check
# $2: (expected) md5 hash of the file
function checkFileMd5 {
    md5sum "$1" | cut -d' ' -f1 | grep -o "$2" > /dev/null
    return $?
}

###############################################################################
# define rstudio version here
# make necessary adjustments when using a newer versions
declare -r pkgname="rstudio"
declare -r pkgver="1.2.1335"
declare -r arch="amd64"
declare -r debfile="${pkgname}-${pkgver}-${arch}.deb"
declare -r url="https://download1.rstudio.org/desktop/bionic/${arch}/${debfile}"
declare -r md5sum="71a8d1990c0d97939804b46cfb0aea75"

###############################################################################

function install_builddeps() {
    # install curl
    echo ">>> Installing prerequisites..."
    sudo apt update && sudo apt install --assume-yes curl
}

function retrieve_source() {
    # download package
    echo ">>> Downloading rstudio package, if required"
    if [[ -e "$PKGDIR/$debfile" ]] && checkFileMd5 "$PKGDIR/$debfile" "$md5sum"; then
        echo ">>> No download necessary, using cached version."
    else
        curl -L "$url" -o "$PKGDIR/$debfile"

        echo -n ">>> Verifying checksum... "
        if ! checkFileMd5 "$PKGDIR/$debfile" "$md5sum"; then
            echo "FAIL"
            echo ">>> Downloaded rstudio package '$PKGDIR/$debfile' does not match md5sum '$md5sum'." >> /dev/stderr
            echo ">>> Aborting." >> /dev/stderr
            exit 1
        fi
        echo "OK"

        echo ">>> rstudio package has been downloaded."
    fi
}

###############################################################################

install_builddeps
retrieve_source
# fix package name
dpkg-name -o "$PKGDIR/$debfile"
