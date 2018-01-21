#!/bin/bash

# TODO
# - add some options for finer grained control over what to clean-up

##
# abort on error
set -e

declare -r SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
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
declare -r PKGCHROOT="$(readlink -f "$SCRIPTDIR/..")/sarbian-xfce/config/packages.chroot/"
declare -r INCLUDESCHROOT="$(readlink -f "$SCRIPTDIR/..")/sarbian-xfce/config/includes.chroot/"

echo ">>> Emptying packages.chroot..."
rm -rf "$PKGCHROOT"/*
echo ">>> Removing files placed by build scripts from includes.chroot..."
rm -rf "$INCLUDESCHROOT/usr/local/bin/"
rm -rf "$INCLUDESCHROOT/usr/local/share/SNAP_Icon_48.png"
rm -rf "$INCLUDESCHROOT/usr/local/share/applications/"

echo ">>> Clean-up finished."
