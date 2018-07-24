# Introduction

SARbian is built with Debian's `live-build` and based on the configuration for the Debian XFCE live media. If you want to build the SARbian
live system on your own, please read the **whole** document first.

# Requirements

- a 64-bit Debian system (graphical environment not required)
- approximately 30 GB of empty disk space
- (recommended) 8 GB memory
- (recommended) a quadcore CPU

It does not need to be a bare metal machine, a virtual machine with proper
hardware configuration is ok, too.

**Note 1:** As some of the software packaging scripts install packages only necessary to
compile and package software, we recommend setting up a system only used for building images.

**Note 2:** While `live-build` is also available in Ubuntu, we have never tried
to build a SARbian image on Ubuntu. Chances are, that some packages that are
required by our packaging scripts or that are configured to be installed in the
live system are not available in Ubuntu.

# Building the iso file

Simply run `sudo ./scripts/build.sh` to start the whole build process. When the
build process has completed, which can take up to 1 to 2 hours, the image can be
found at `sarbian-xfce/live-image-amd64.hybrid.iso`.

# Build scripts and configuration

The repository contains two directories at its root:
- `sarbian-xfce` and
- `scripts`

## `sarbian-xfce`

This folder contains the configuration that `live-build` uses to build the
image, in addition it is the place, the image is built in. Thus it is referred
to as **build tree** in the following.

Only some important files and directories are covered here; to fully
understand the purpose of each file and directory, please read the
[manual](https://live-team.pages.debian.net/live-manual/html/live-manual/about-manual.en.html)
of `live-build`.

### `auto/config`

Collects the configuration options for `lb config`, e.g. whether to create an
installer, which kernel to use, metadata for the resulting iso file and from
which APT repositories should be enabled.

### `config/hooks/live`

Contains shell scripts that are run in the chroot stage when the image is built,
i.e. they are executed in the filetree of the image in a chroot environment.
We currently use them to install packages for R, Python and to install SNAP.

### `config/includes.chroot`

Contains files that are copied into the filetree of the image. The structure must
be the same as in the resulting image, i.e. files that should go into `/etc`,
should be placed here into `/etc` as well.  
Amongst other things, we use it for configuring APT Pinning (`etc/apt`) and the
configuration of the XFCE Desktop (`etc/skel/.config`).

### `config/package-lists`

The package lists contain all the packages that are to be installed from the Debian
repositories activated in `auto/config`. The relevant lists for SARbian
are `sarbian.list.chroot`, which lists packages related to SAR processing and
`sarbian-desktop.list.chroot`, which lists packages for the XFCE Desktop and
other more general software, like Firefox and LibreOffice.

#### `config/packages.chroot`

Not existent in this repository, this directory is created by the software
packaging scripts described below. All additional packages (\*.DEB) files, that
should be included in the image are placed here.

## `scripts`

### `build.sh`

The main build script for starting the build process for the SARbian iso image.
It installs `live-build` if required, cleans up the build environment
(`cleanup.sh`), runs our packaging scripts (`collect-packages.sh`) and then
runs `lb build` to build the live image.

### `cleanup.sh`

Cleans the build tree under `sarbian-xfce` and removes the build directories
the packaging scripts created.

### `collect-packages.sh`

Calls all of the scripts that create or download Debian packages and copies the
packages into `config/packages.chroot` in the build tree. Only scripts in the
same directory, prefixed with either `package-` or `download-` are automatically
found and run.

### `download-*.sh`

Scripts to download either Debian packages (e.g. for RStudio) or other files
(e.g. in case of SNAP it is the SNAP installer).

### `package-*.sh`

Scripts to download and compile source code and create Debian packages.
