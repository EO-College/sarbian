#!/bin/bash
#
# cleanup.sh - clean the image build environment
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

# TODO
# - add some options for finer grained control over what to clean-up

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
# remove directories created by our own build scripts
declare -r CACHEDIR="${SCRIPTDIR}/cache"
declare -r BUILDDIR="${SCRIPTDIR}/build"
declare -r PKGDIR="${SCRIPTDIR}/pkg"

echo ">>> Removing cache directory..."
rm -rf "$CACHEDIR"
echo ">>> Removing build directory..."
rm -rf "$BUILDDIR"
echo ">>> Removing package directory..."
rm -rf "$PKGDIR"

##
# remove files our build scripts placed in the image build tree
declare -r PKGCHROOT="$SCRIPTDIR/../sarbian-xfce/config/packages.chroot"
declare -r INCLUDESCHROOT="$SCRIPTDIR/../sarbian-xfce/config/includes.chroot"

echo ">>> Emptying packages.chroot..."
rm -rf "${PKGCHROOT:?}"/*
echo ">>> Removing files placed by build scripts from includes.chroot..."
rm -rf "$INCLUDESCHROOT/usr/local/bin/"
rm -rf "$INCLUDESCHROOT/usr/local/share/SNAP_Icon_48.png"
find "$INCLUDESCHROOT/usr/local/share/applications/" -mindepth 1 -not -name "mimeapps.list" -print -delete

echo ">>> Clean-up finished."
