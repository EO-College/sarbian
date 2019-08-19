#!/bin/bash
#
# package-asfmapready.sh - download and packaging script for ASF MapReady
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
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
readonly SCRIPTDIR
declare -r CACHEDIR="${SCRIPTDIR}/cache"
declare -r BUILDDIR="${SCRIPTDIR}/build"
declare -r PKGDIR="${SCRIPTDIR}/pkg"

###############################################################################
# make necessary adjustments when using a newer version
declare -r pkgname="asf-mapready"
declare -r _pkgname="ASF_MapReady"
# make sure to use the same version number as used in debian/changelog here!
declare -r pkgver="0~20190630"
declare -r pkgrel="1"
declare -r arch="amd64"
# we cannot just download the tarballs from our tags, we need the whole .git
# directory for creating the changelog
declare -r repourl="https://github.com/EO-College/${_pkgname}"
declare -r vcstag="sarbian-19.08"

declare -r makedepends=(\
    "curl" \
    "build-essential" \
    "devscripts" \
    "debhelper" \
    "lintian" \
    "libgsl-dev" \
    "libproj-dev" \
    "libglib2.0" \
    "libjpeg-dev" \
    "libtiff5-dev" \
    "libpng-dev" \
    "libgeotiff-dev" \
    "libshp-dev" \
    "libfftw3-dev" \
    "libxml2-dev" \
    "libgdal-dev" \
    "libcunit1-dev" \
    "flex" \
    "bison" \
    "libgtk2.0-dev" \
    "libglade2-dev" \
    "libexif-dev" \
)

declare -r AMR_PKG_FILES="$SCRIPTDIR/asf-mapready-pkg-files"
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
    git fetch --all --tags --prune
    git checkout tags/"$vcstag"

    popd > /dev/null
}

function prepare() {
    echo ">>> Patching files that quilt cannot patch..."
    # turn CRLF into LF so the quilt can successfully patch
    sed --in-place 's/\r//g' "${AMR_SRCDIR}/src/auto_refine_base/auto_refine_base.c"

    echo ">>> Copying packaging files..."
    # copy debian packaging files
    rm -rf "$AMR_SRCDIR/debian"
    cp -r "$AMR_PKG_FILES/debian" "$AMR_SRCDIR/debian"
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
