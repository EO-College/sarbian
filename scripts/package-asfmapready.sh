#!/bin/bash

# Packaging script for ASF MapReady

##
# abort on error
set -e

##
# define important directories
declare -r SCRIPTDIR="$(readlink -f "$(dirname "$0")")"
declare -r CACHEDIR="${SCRIPTDIR}/cache"
declare -r BUILDDIR="${SCRIPTDIR}/build"
declare -r PKGDIR="${SCRIPTDIR}/pkg"

###############################################################################
# install build dependencies
echo ">>> Installing build dependencies..."
sudo apt update
sudo apt --assume-yes install \
    "curl" \
    "build-essential" \
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
    "libexif-dev"

###############################################################################
# download the ASF_MapReady devel branch from GitHub as a tarball
mkdir -p "$CACHEDIR"
echo ">>> Retrieving source code..."
tarball="asf-mapready.tar.gz"
if [[ ! -e "${CACHEDIR}/${tarball}" ]]; then
    curl -L -o "${CACHEDIR}/${tarball}" "https://github.com/ikselven/ASF_MapReady/archive/devel.tar.gz"
fi

###############################################################################
# extract the source code
mkdir -p "$BUILDDIR" && cd "$BUILDDIR"
srcdir="${BUILDDIR}/ASF_MapReady-devel"
rm -rf "$srcdir"
echo ">>> Extracting ${tarball}..."
tar -xzf "${CACHEDIR}/${tarball}"

###############################################################################
# compile
cd "$srcdir"
echo ">>> Compiling and packaging software..."
./configure --prefix=/usr
make deb

###############################################################################
# post-packaging
echo ">>> Post-packaging..."
mkdir -p "$PKGDIR"
mv -v "${BUILDDIR}/ASF_MapReady-devel/asf-mapready.deb" "$PKGDIR"
dpkg-name -o "${PKGDIR}/asf-mapready.deb"

# TODO: include desktop file in package
echo ">>> Creating desktop file for 'asf_view'..."
echo "#!/usr/bin/env xdg-open
[Desktop Entry]
Type=Application
Name=ASF_View
Exec=/usr/bin/asf_view
Categories=Application;Geography;" > "$BUILDDIR/asf_view.desktop"

declare -r INCLUDES_CHROOT="$(readlink -f "$SCRIPTDIR/..")/sarbian-xfce/config/includes.chroot/usr/local/share/applications"
mkdir -p "$INCLUDES_CHROOT"
echo ">>> Copying ASF View desktop file into '$INCLUDES_CHROOT'..."
cp -v "$BUILDDIR/asf_view.desktop" "$INCLUDES_CHROOT"

echo ">>> Finished packaging 'asf-mapready'"
