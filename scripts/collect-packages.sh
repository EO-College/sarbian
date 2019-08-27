#!/bin/bash
#
# collect-packages.sh - download/package software and place it in build tree
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

SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPTDIR
if [[ -z "$SCRIPTDIR" ]]; then
    echo "Fatal Error: cannot determine the absolute path to '$0'." >> /dev/stderr
    exit 1
fi

##
# run all scripts that create package files
echo ">>> Starting package building..."
for pkgscript in "$SCRIPTDIR/package-"*".sh"; do
    echo ">>> Running package script '$pkgscript'..."
    "$pkgscript"
done

##
# run all scripts that download packages or installers
echo ">>> Starting package/installer downloading..."
for pkgscript in "$SCRIPTDIR/download-"*".sh"; do
    echo ">>> Running download script '$pkgscript'..."
    "$pkgscript"
done

echo ">>> Packages have been successfully built/downloaded."

##
# copy package files into image build tree
declare -r PKGLISTS="$SCRIPTDIR/sarbian-xfce/config/packages.chroot/"
mkdir -p "$PKGLISTS"
echo ">>> Copying packages into '$PKGLISTS'..."
cp -v "$SCRIPTDIR/pkg/"*.deb "$PKGLISTS"

echo ">>> Custom built/Downloaded packages have been placed in live build environment."
