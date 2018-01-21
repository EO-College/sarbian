#!/bin/bash

# Download and packaging script for PolSARPro

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
# make necessary adjustments when using a newer versions
declare -r pkgname="polsarpro"
declare -r pkgver="5.0.4"
declare -r arch="amd64"
declare -r file="PolSARpro_v${pkgver}_Linux_20150607.rar"
declare -r url="https://earth.esa.int/documents/653194/1960708/${file%.rar}"
declare -r md5sum="99ad2b0165eb36fed82cb88361fd2161"

declare -r PP_PKG_FILES="$SCRIPTDIR/polsarpro-pkg-files"
declare -r PP_BUILDDIR="$BUILDDIR/${pkgname}"
declare -r PP_SRCDIR="$PP_BUILDDIR/src"
declare -r PP_PKGDIR="$PP_BUILDDIR/pkg"

mkdir -p "$CACHEDIR" "$PP_SRCDIR" "$PP_PKGDIR"

###############################################################################

function install_builddeps() {
    # install curl, unrar and fakeroot as build deps
    echo ">>> Installing prerequisites..."
    sleep 0.1
    sudo apt update
    sudo apt install --assume-yes curl unrar fakeroot
}

function retrieve_source() {
    # download package
    echo ">>> Downloading PolSARpro archive, if required"
    if [[ -e "$CACHEDIR/$file" ]] && $(checkFileMd5 "$CACHEDIR/$file" "$md5sum"); then
        echo ">>> No download necessary, using cached version."
    else
        curl -L "$url" -o "$CACHEDIR/$file"

        echo -n ">>> Verifying checksum... "
        if ! $(checkFileMd5 "$CACHEDIR/$file" "$md5sum"); then
            echo "FAIL"
            echo ">>> Downloaded PolSARpro archive '$CACHEDIR/$file' does not match md5sum '$md5sum'." >> /dev/stderr
            echo ">>> Aborting." >> /dev/stderr
            exit 1
        fi
        echo "OK"

        echo ">>> PolSARpro archive has been downloaded."
    fi
}

function extract_files() {
    echo ">>> Extracting source..."
    # extract files
    unrar x "$CACHEDIR/$file" "$PP_SRCDIR"
}

function build() {
    echo ">>> Running necessary compilation steps..."
    cp -v "$PP_PKG_FILES/compile-code.sh" "$PP_SRCDIR/Soft"
    (cd "$PP_SRCDIR/Soft" && ./compile-code.sh && rm ./compile-code.sh)
    # fix permissions
    find "$PP_SRCDIR/Soft" -type d -o -name '*.exe' -exec chmod 755 {} +
    find "$PP_SRCDIR/Soft" -type f ! -name '*.exe' -exec chmod 644 {} +

    # configure software
    echo "/usr/bin/gimp" > "$PP_SRCDIR/Config/GimpUnix.txt"
    echo "/usr/bin/convert" > "$PP_SRCDIR/Config/ImageMagickUnix.txt"
}

function create_package() {
    echo ">>> Creating package..."
    # create polsarpro opt dir
    mkdir -p "$PP_PKGDIR/opt/${pkgname}"
    # and copy polsarpro files into it for now
    cp -r "$PP_SRCDIR"/* "$PP_PKGDIR/opt/${pkgname}/"
    # copy license txt file
    install -Dm644 "$PP_PKG_FILES/copyright" "$PP_PKGDIR/usr/share/doc/${pkgname}/copyright"
    # launcher for polsarpro
    install -Dm755 "$PP_PKG_FILES/polsarpro" "$PP_PKGDIR/usr/bin/polsarpro"
    chmod 755 "$PP_PKGDIR/opt/polsarpro/PolSARpro_v5.0.tcl"

    # remove unnecessary files
    rm -rf "$PP_PKGDIR/opt/${pkgname}/Soft/Compil_PolSARpro_v5_Linux.bat"
    # we place a text file with the license into the correct directory, so the
    # pdf is obsolete
    rm -rf "$PP_PKGDIR/opt/${pkgname}/license.pdf"

    mkdir -p "$PP_PKGDIR/DEBIAN"
    # global configs for etc
    #touch "$PP_PKGDIR/DEBIAN/conffiles"
    # package metadata
    cp "$PP_PKG_FILES/control" "$PP_PKGDIR/DEBIAN/control"
    sed -i \
        -e "s/PKG_NAME/$pkgname/" \
        -e "s/PKG_VER/$pkgver/" \
        -e "s/ARCH/$arch/" \
        -e "s/INSTALLED_SIZE/$(du -sc "$PP_PKGDIR"/{opt,usr} | tail -1 | cut -d$'\t' -f1)/" "$PP_PKGDIR/DEBIAN/control"
    # checksums
    find "$PP_PKGDIR/opt" -type f -exec sha256sum {} + > "$PP_PKGDIR/DEBIAN/sha256sums"

    # post-installation
    #touch "$PP_PKGDIR/DEBIAN/postinst"
    # pre-remove
    #touch "$PP_PKGDIR/DEBIAN/prerm"

    # wrap up everything
    mkdir -p "$PKGDIR"
    dpkg-deb -b "$PP_PKGDIR" "$PKGDIR/${pkgname}_${pkgver}_${arch}.deb"
    dpkg-name -o "${PKGDIR}/${pkgname}_${pkgver}_${arch}.deb"
}

###############################################################################

if [[ "$1" == "-F" ]]; then
    declare -r INFAKEROOT=1
fi

if [[ "$INFAKEROOT" ]]; then
    create_package || exit 1
    exit 0
else
    install_builddeps
    retrieve_source
    extract_files
    build
    fakeroot -- $0 -F
fi

echo "Finished building Debian package for $pkgname."
