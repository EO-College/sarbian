#!/bin/bash
#
# package-gmtsar.sh - download and packaging script for GMTSAR/GMT5SAR
#
# Copyright (C) 2019 Felix Glaser
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
declare -r CACHEDIR="${SCRIPTDIR}/cache"
declare -r BUILDDIR="${SCRIPTDIR}/build"
declare -r PKGDIR="${SCRIPTDIR}/pkg"

###############################################################################
# make necessary adjustments when using a newer version
declare -r pkgname="gmtsar"
# make sure to use the same version number as used in debian/changelog here!
declare -r pkgver="5.7"
declare -r pkgrel="1"
declare -r arch="amd64"
# we cannot just download the tarballs from our tags, we need the whole .git
# directory for creating the changelog
declare -r repourl="https://github.com/gmtsar/${pkgname}"

declare -ar makedepends=(
    "git"
    "devscripts"
    "debhelper"
    "lintian"
    "cmake"
    "tcsh"
    "autoconf"
    "libtiff5-dev"
    "libhdf5-dev"
    "gfortran"
    "g++"
    "libgmt-dev"
    "gmt"
    "libblas-dev"
    "liblapack-dev"
)

declare -r AMR_PKG_FILES="$SCRIPTDIR/gmtsar-pkg-files"
declare -r AMR_BUILDDIR="$BUILDDIR/${pkgname}"
declare -r AMR_SRCDIR="$AMR_BUILDDIR/${pkgname}-${pkgver}"

[[ -e "$AMR_SRCDIR" ]] && rm -rf "$AMR_SRCDIR"
mkdir -p "$CACHEDIR" "$AMR_SRCDIR"

###############################################################################

function install_builddeps() {
    # install build dependencies
    echo ">>> Installing build dependencies..."
    sudo apt update
    sudo apt --assume-yes install "${makedepends[@]}"
}

function retrieve_source() {
    echo ">>> Cloning '$repourl' into '${AMR_SRCDIR}'..."
    # clone the EO-College fork of ASF MapReady
    pushd "${AMR_BUILDDIR}" > /dev/null

    git clone "${repourl}" "${pkgname}-${pkgver}"
    cd "${AMR_SRCDIR}"
    git checkout "$pkgver"

    popd > /dev/null
}

function prepare() {
    echo ">>> Copying packaging files..."
    # copy debian packaging files
    cp -r "$AMR_PKG_FILES/debian" "$AMR_SRCDIR/debian"

    # delete broken symlinks quilt refuses to delete
    rm -rf "${AMR_SRCDIR:?}/lib" "${AMR_SRCDIR:?}/preproc/S1A_preproc/include/include"
}

function create_package() {
    echo ">>> Creating package..."
    cd "$AMR_SRCDIR"
    # run debuild
    debuild -b -uc -us
    # copy package into collective pkg directory
    mkdir -p "$PKGDIR"
    cp -v "$AMR_BUILDDIR/${pkgname}_${pkgver}-${pkgrel}_${arch}.deb" "$PKGDIR"
}

###############################################################################

install_builddeps
retrieve_source
prepare
create_package

echo "Finished building Debian package for $pkgname."
