#!/bin/bash
#
# package-polsarpro.sh - download and packaging script for PolSARPro
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
# make necessary adjustments when using a newer versions
declare -r pkgname="polsarpro"
declare -r pkgver="6.0.1"
declare -r arch="amd64"
declare -r file="${pkgname}-${pkgver}.tar.gz"
declare -r url="https://github.com/EO-College/${pkgname}/archive/v${pkgver}.tar.gz"
declare -r sha256sum="315230079a28940fed67171a38b636ee214c7d945887eabc6bf5af2faac1123b"

declare -r PP_PKG_FILES="$SCRIPTDIR/polsarpro-pkg-files"
declare -r PP_BUILDDIR="$BUILDDIR/${pkgname}"
declare -r PP_SRCDIR="$PP_BUILDDIR/src/${pkgname}-${pkgver}"
declare -r PP_PKGDIR="$PP_BUILDDIR/pkg"

###############################################################################

function install_builddeps() {
    # install curl, fakeroot and some libraries as builddeps
    echo ">>> Installing prerequisites..."
    sleep 0.1
    sudo apt update
    sudo apt install --assume-yes curl fakeroot freeglut3-dev libfreeimage-dev libglew-dev
}

function retrieve_source() {
    # download package
    echo ">>> Downloading PolSARpro archive, if required"
    if [[ -e "$CACHEDIR/$file" ]] && checkFile "$CACHEDIR/$file" "$sha256sum"; then
        echo ">>> No download necessary, using cached version."
    else
        curl -L "$url" -o "$CACHEDIR/$file"

        echo -n ">>> Verifying checksum... "
        if ! checkFile "$CACHEDIR/$file" "$sha256sum"; then
            echo "FAIL"
            echo ">>> Downloaded PolSARpro archive '$CACHEDIR/$file' does not match sha256sum '$sha256sum'." >> /dev/stderr
            echo ">>> Aborting." >> /dev/stderr
            exit 1
        fi
        echo "OK"

        echo ">>> PolSARpro archive has been downloaded."
    fi
}

function extract_files() {
    [[ -e "$PP_BUILDDIR" ]] && rm -rf "$PP_BUILDDIR"
    mkdir -p "$CACHEDIR" "$PP_SRCDIR" "$PP_PKGDIR"

    echo ">>> Extracting source..."
    # extract files
    tar -xzf "$CACHEDIR/$file" -C "$PP_SRCDIR/.."
}

function prepare() {
    echo ">>> Doing some preparations before building..."
    # delete bin directory because it contains windows binaries
    rm -rf "$PP_SRCDIR/Soft/bin"
    # delete object file from src directory
    rm -rf "$PP_SRCDIR/Soft/src/lib/PolSARproLib.o"

    # PolSARpro comes with executables for h5dump, 7za, curl and gnuplot
    # these must not be included in the final package as they are provided by
    # their Debian packages.
    # gnuplot from gnuplot, patch seems not necessary, uses /usr/bin/gnuplot on Linux/Unix
    # h5dump from hdf5-tools, patch ./PolSARpro_v6.0_Biomass_Edition.tcl
    patch -d "$PP_SRCDIR" -Np1 -i "$PP_PKG_FILES/patches/0001-use-system-provided-h5dump.patch"
    # 7za from p7zip-full, patch ./GUI/data_import/SENTINEL1_Input_Zip_File.tcl
    patch -d "$PP_SRCDIR" -Np1 -i "$PP_PKG_FILES/patches/0002-use-system-provided-7za.patch"
    # curl from curl, patch ./PolSARpro_v6.0_Biomass_Edition.tcl
    patch -d "$PP_SRCDIR" -Np1 -i "$PP_PKG_FILES/patches/0003-use-system-provided-curl.patch"

    # remove the external dependencies shipping with PolSARpro
    rm -rf "$PP_SRCDIR/Soft/lib/"{curl,hdf5,unzip,wgnuplot}

    # copy the remaining files into the bin directory
    mkdir -p "$PP_SRCDIR/Soft/bin/lib"
    find "$PP_SRCDIR/Soft/src/lib/" -mindepth 1 -maxdepth 1 -type d \
        -not -name "alglib" -exec cp -r {} "$PP_SRCDIR/Soft/bin/lib" \;

    # copy our own Makefiles into the src directories
    cp -v "$PP_PKG_FILES/makefiles/"{Makefile,Compile.make} "$PP_SRCDIR/Soft/src"

    local -ar subdirs=(
        basis_change
        bmp_process
        calculator
        calibration
        data_convert
        data_import
        data_process_dual
        data_process_mult
        data_process_sngl
        speckle_filter
        tools
    )
    for subdir in "${subdirs[@]}"; do
        cp -v "$PP_PKG_FILES/makefiles/SubMakefile" "$PP_SRCDIR/Soft/src/$subdir/Makefile"
    done

    local -ar subdirs2=(
        PolSARap
        PolSARproSIM
        PolSARproSIMgr
        PolSARproSIMsv
        SVM
    )

    for subdir2 in "${subdirs2[@]}"; do
        cp -v "$PP_PKG_FILES/makefiles/${subdir2}_Makefile" "$PP_SRCDIR/Soft/src/${subdir2}/Makefile"
    done

    for w in psp satim; do
        cp -v "$PP_PKG_FILES/makefiles/map_algebra_${w}_Makefile" \
            "$PP_SRCDIR/Soft/src/map_algebra_${w}/linux/map_algebra/Makefile"
    done
}

function build() {
    echo ">>> Building PolSARPro 6.0.1..."
    (cd "$PP_SRCDIR/Soft/src" && make clean && make -j)
    cp -v "$PP_SRCDIR/Soft/bin/map_algebra/linux/map_algebra_psp.exe" "$PP_SRCDIR/Soft/bin/map_algebra/linux/map_algebra_gimp.exe"

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
    install -Dm644 "$PP_SRCDIR/License/PolSARpro_v6.0_Biomass_Edition_LICENSE.txt" "$PP_PKGDIR/usr/share/doc/${pkgname}/copyright"
    # launcher for polsarpro
    install -Dm755 "$PP_PKG_FILES/polsarpro" "$PP_PKGDIR/usr/bin/polsarpro"
    # desktop file for polsarpro
    install -Dm644 "$PP_PKG_FILES/polsarpro.desktop" "$PP_PKGDIR/usr/share/applications/polsarpro.desktop"

    # remove unnecessary files
    rm -rf "$PP_PKGDIR/opt/${pkgname}/Soft/src"
    rm -rf "$PP_PKGDIR/opt/${pkgname}/Soft/Compil_PolSARpro_Biomass_Edition_Linux.sh"
    rm -rf "$PP_PKGDIR/opt/${pkgname}/GUI/Images/Thumbs.db"
    rm -rf "$PP_PKGDIR/opt/${pkgname}/GUI/Images/GPT/Thumbs.db"

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
    prepare
    build
    fakeroot -- "$0" -F
fi

echo "Finished building Debian package for $pkgname."
