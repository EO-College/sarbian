#!/bin/bash

# Download and packaging script for ASF MapReady

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
# make necessary adjustments when using a newer version
declare -r pkgname="asf-mapready"
declare -r _pkgname="ASF_MapReady"
# make sure to use the same version number as used in debian/changelog here!
declare -r pkgver="0~20180618"
# at the moment the name of the tag in EO-College/ASF_MapReady the package is built from
declare -r _pkgver="sarbian-18.08"
declare -r arch="amd64"
declare -r file="${_pkgname}-${_pkgver}.tar.gz"
declare -r url="https://github.com/EO-College/${_pkgname}/archive/${_pkgver}.tar.gz"
declare -r sha256sum="934de9bfe094f64c0dba04bc4d4b2ddcaf834b06e862ef8c8b0fdc16f0124cb5"

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
declare -r AMR_SRCDIR="$AMR_BUILDDIR/${_pkgname}-${_pkgver}"

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
    # download package
    echo ">>> Downloading ASF MapReady archive, if required"
    if [[ -e "${CACHEDIR}/$file" ]] && $(checkFile "$CACHEDIR/$file" "$sha256sum"); then
        echo ">>> No download necessary, using cached version."
    else
        curl -L "$url" -o "${CACHEDIR}/$file"

        echo -n ">>> Verifying checksum..."
        if ! $(checkFile "$CACHEDIR/$file" "$sha256sum"); then
            echo "FAIL"
            echo ">>> Downloaded ASF MapReady archive '$CACHEDIR/$file' does not match sha256sum '$sha256sum'." >> /dev/stderr
            echo ">>> Aborting." >> /dev/stderr
            exit 1
        fi
        echo "OK"

        echo ">>> ASF MapReady archive has been downloaded."
    fi
}

function extract_files() {
    # extract files
    echo ">>> Extracting source..."
    tar -xzf "$CACHEDIR/$file" -C "$AMR_SRCDIR/.."
}

function prepare() {
    echo ">>> Applying patches..."
    pushd "$AMR_SRCDIR" > /dev/null

    # turn CRLF into LF to be able to apply patch 01
    sed --in-place 's/\r//g' "src/auto_refine_base/auto_refine_base.c"

    # apply patches
    # TODO: use quilt or dpatch for patch management
    # replaces self-built bool with the one from stdbool.h
    patch --ignore-whitespace -p1 -i"$AMR_PKG_FILES/patches/01-boolean-fixes.patch"
    # remove entry for object file that has no source anymore
    patch --ignore-whitespace -p1 -i"$AMR_PKG_FILES/patches/02-dem-makefile-fix.patch"
    # introduce a changelog target in the Makefile
    patch --ignore-whitespace -p1 -i"$AMR_PKG_FILES/patches/03-changelog-makefile.patch"

    popd > /dev/null

    echo ">>> Copying packaging files..."
    # copy debian packaging files
    rm -rf "$AMR_SRCDIR/debian"
    cp -r "$AMR_PKG_FILES/debian" "$AMR_SRCDIR/debian"

    # copy desktop file into src directory
    install -Dm644 "$AMR_PKG_FILES/asf_view.desktop" "$AMR_SRCDIR/share/applications/asf_view_desktop"
}

function create_package() {
    echo ">>> Creating package..."
    cd "$AMR_SRCDIR"
    # run debuild
    debuild -b -uc -us
    # copy package into collective pkg directory
    mkdir -p "$PKGDIR"
    cp -v "$AMR_BUILDDIR/${pkgname}_${pkgver}_${arch}.deb" "$PKGDIR"
}

###############################################################################

install_builddeps
retrieve_source
extract_files
prepare
create_package

echo "Finished building Debian package for $pkgname."
