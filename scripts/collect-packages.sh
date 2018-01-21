#!/bin/bash

##
# abort on error
set -e

declare -r SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
if [[ -z "$SCRIPTDIR" ]]; then
    echo "Fatal Error: cannot determine the absolute path to '$0'." >> /dev/stderr
    exit 1
fi

##
# define important directories
declare -r CACHEDIR="${SCRIPTDIR}/cache"
declare -r BUILDDIR="${SCRIPTDIR}/build"
declare -r PKGDIR="${SCRIPTDIR}/pkg"

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
declare -r PKGLISTS="$(readlink -f "$SCRIPTDIR/..")/sarbian-xfce/config/packages.chroot/"
mkdir -p "$PKGLISTS"
echo ">>> Copying packages into '$PKGLISTS'..."
cp -v "$SCRIPTDIR/pkg/"*.deb "$PKGLISTS"

echo ">>> Custom built/Downloaded packages have been placed in live build environment."
