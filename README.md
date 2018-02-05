# SARbian
SARbian is a Linux live system based on Debian Stretch (Debian 9) coming with free SAR processing software tools pre-installed, ready to use.
For now, there is only a version for 64 bit systems.

This repository contains the scripts to build the SARbian iso file.
Go to https://eo-college.org/sarbian#download to download a prebuilt SARbian iso.

Simply burn the image on a DVD or install it on a USB key. When booting from the DVD/USB key, choose:

- one of the "Live" options if you want to use the system without installing anything
- one of the "Install" options to install SARbian on your computer

The live system will automatically start a graphical session. In case it is necessary, the login data is "saredu" with password "sarbian".

**As with most live systems:**  
Keep in mind, that when using SARbian in live mode, changes and files that are not saved elsewhere (Cloud Storage, another USB key, etc.) are lost when you power off your computer.

## SAR Processing Software
The following software is installed for the processing and handling of SAR data.

|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[ESA SNAP and Sentinel-1 Toolbox](http://step.esa.int/main/toolboxes/snap/) | [SNAP Installer](http://step.esa.int/main/download/)| GPL-3.0|
|[PolSARPro 5.0](https://earth.esa.int/web/polsarpro/home)| own package build| GPL-2.0|
|[ASF MapReady](https://github.com/asfadmin/ASF_MapReady)| own package build|GPL-3.0|
|[GDAL](gdal.org)| Debian repository| [X11/MIT](https://trac.osgeo.org/gdal/wiki/FAQGeneral#WhatexactlywasthelicensetermsforGDAL)
|[QGIS](qgis.org)| Debian repository <br> APT pinning configured for QGIS from backports|GPL-2.0|
|[GRASS GIS](https://grass.osgeo.org/)| Debian repository|GPL-2.0|
|[DORIS](http://doris.tudelft.nl/usermanual/index.html)| Debian repository|GPL-3.0|
|[SNAPHU](https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/)| Debian repository| [common](http://metadata.ftp-master.debian.org/changelogs/non-free/s/snaphu/snaphu_1.4.2-2_copyright)|
|[Python 2 and 3](python.org), incl. pip| Debian repository|python-2.0|
|[R (r-base)](https://www.r-project.org/)| Debian repository|GPL-2.0|
|[pyroSAR](https://github.com/johntruckenbrodt/pyroSAR)| via pip from github|MIT|
|[PyRAT](https://github.com/birgander2/PyRAT)| via pip from github|MPL-2.0|
|[RStudio](rstudio.com)| Debian package from rstudio.com|AGPL-3.0|
|[R Shiny](https://shiny.rstudio.com/)| via R package manager|GPL-3.0|

## Utility Software
|Utility|Software Name |
|-------------|--------------|
|Desktop| preconfigured XFCE 4|
|Browser| Firefox|
|Office | LibreOffice|
|Text Editor| Mousepad|

## Help to build SARbian

If you want to help building SARbian you should have a look at the [developer manual](DEVEL.md)
and the [Live Systems Manual](https://debian-live.alioth.debian.org/live-manual/stable/manual/html/live-manual.en.html#1).

## Acknowledgement

We would like to thank the [Debian Project](https://debian.org) and the [Debian Live Project](https://wiki.debian.org/DebianLive).

SARbian is provided by the [EO College](https://eo-college.org) and was developed in the framework of the project SAR-EDU.

SAR-EDU is funded by the Federal Ministry of Economics and Technology, on the basis of a decision by the German Bundestag.
