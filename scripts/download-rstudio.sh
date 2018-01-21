#!/bin/bash

# Download and install script for RStudio

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
declare -r pkgver="1.1.383"
declare -r arch="amd64"
declare -r debfile="${pkgname}-xenial-${pkgver}-${arch}.deb"
declare -r url="https://download1.rstudio.org/${debfile}"
declare -r md5sum="fccec7cbf773c3464ea6cbb91fc2ec28"

###############################################################################

function install_builddeps() {
    # install curl
    echo ">>> Installing prerequisites..."
    sudo apt update && sudo apt install --assume-yes curl
}

function retrieve_source() {
    # download package
    echo ">>> Downloading rstudio package, if required"
    if [[ -e "$PKGDIR/$debfile" ]] && $(checkFileMd5 "$PKGDIR/$debfile" "$md5sum"); then
        echo ">>> No download necessary, using cached version."
    else
        curl -L "$url" -o "$PKGDIR/$debfile"

        echo -n ">>> Verifying checksum... "
        if ! $(checkFileMd5 "$PKGDIR/$debfile" "$md5sum"); then
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
