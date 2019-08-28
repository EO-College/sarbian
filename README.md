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

### General SAR Processing
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[ESA SNAP and Sentinel-1 Toolbox](http://step.esa.int/main/toolboxes/snap/) | [SNAP Installer](http://step.esa.int/main/download/)| GPL-3.0|
|[ASF MapReady](https://github.com/asfadmin/ASF_MapReady)| own package build|GPL-3.0|
|[pyroSAR](https://github.com/johntruckenbrodt/pyroSAR)| via pip from PyPI|MIT|

### SAR polarimetry
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[PolSARPro 6.0](https://earth.esa.int/web/polsarpro/home)| own package build| GPL-2.0|

### SAR interferometry
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[DORIS](http://doris.tudelft.nl/usermanual/index.html)| Debian repository|GPL-3.0|
|[SNAPHU](https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/)| Debian repository| [common](http://metadata.ftp-master.debian.org/changelogs/non-free/s/snaphu/snaphu_1.4.2-2_copyright)|
|[PyRAT](https://github.com/birgander2/PyRAT)| via pip from github|MPL-2.0|

### GIS
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[GDAL](gdal.org)| Debian repository| [X11/MIT](https://trac.osgeo.org/gdal/wiki/FAQGeneral#WhatexactlywasthelicensetermsforGDAL)
|[QGIS](qgis.org)| Debian repository <br> APT pinning configured for QGIS from backports|GPL-2.0|
|[GRASS GIS](https://grass.osgeo.org/)| Debian repository|GPL-2.0|

### Python
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[Python 2 and 3](python.org), incl. pip| Debian repository|Python-2.0|
|[matplotlib](https://pypi.org/project/matplotlib/)| via pip from PyPI|Python-2.0| 
|[numpy](https://pypi.org/project/numpy/)| via pip from PyPI|BSD-3-Clause|
|[PyRAT](https://github.com/birgander2/PyRAT)| via pip from Github|MPL-2.0|
|[pyroSAR](https://github.com/johntruckenbrodt/pyroSAR)| via pip from PyPI|MIT|
|[scipy](https://pypi.org/project/scipy/)| via pip from PyPI|BSD-3-Clause|
|[spatialist](https://github.com/johntruckenbrodt/spatialist) | via pip from PyPI|MIT|

### R
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[R (r-base)](https://www.r-project.org/)| Debian repository|GPL-2.0|
|[RStudio](rstudio.com)| Debian package from rstudio.com|AGPL-3.0|
|[abind](https://cran.r-project.org/web/packages/abind/)| via R package manager|LGPL-2.0|
|[caret](https://cran.r-project.org/web/packages/caret/)| via R package manager|GPL-2.0-or-later|
|[cowplot](https://cran.r-project.org/web/packages/cowplot/)| via R package manager|GPL-2.0|
|[dplyr](https://cran.r-project.org/web/packages/dplyr/)| via R package manager|MIT|
|[foreach](https://cran.r-project.org/web/packages/foreach/)| via R package manager|Apache-2.0|
|[ggplot2](https://cran.r-project.org/web/packages/ggplot2/)| via R package manager|GPL-2.0|
|[jpeg](https://cran.r-project.org/web/packages/jpeg/)| via R package manager|GPL-2.0|
|[mapproj](https://cran.r-project.org/web/packages/mapproj/)| via R package manager|LPL-1.02|
|[openair](https://cran.r-project.org/web/packages/openair/)| via R package manager|GPL-2.0-or-later|
|[raster](https://cran.r-project.org/web/packages/raster/)| via R package manager|GPL-3.0|
|[readxl](https://cran.r-project.org/web/packages/readxl/)| via R package manager|GPL-3.0|
|[reshape2](https://cran.r-project.org/web/packages/reshape2/)| via R package manager|MIT|
|[rgdal](https://cran.r-project.org/web/packages/rgdal/)| via R package manager|GPL-2.0|
|[rgeos](https://cran.r-project.org/web/packages/rgeos)| via R package manager|GPL-2.0|
|[scales](https://cran.r-project.org/web/packages/scales)| via R package manager|MIT|
|[shiny](https://cran.r-project.org/web/packages/shiny/)| via R package manager|GPL-3.0|
|[sp](https://cran.r-project.org/web/packages/sp/)| via R package manager|GPL-2.0|

### Octave
|Software name|Installation source |License|
|:-----------|:-----------|:-----------------|
|[Octave](https://www.gnu.org/software/octave/) | Debian repository|GPL-3.0|
|[Computational Geometry](https://octave.sourceforge.io/geometry/)| Debian repository|GPL-3.0, BSD-2-Clause-FreeBSD, BSL-1.0|
|[Image Processing](https://octave.sourceforge.io/image/)| Debian repository|GPL-3.0|
|[Linear algebra](https://octave.sourceforge.io/linear-algebra/)| Debian repository|GPL-3.0, LGPL-3.0, BSD-2-Clause-FreeBSD|
|[Mapping Functions](https://octave.sourceforge.io/mapping)| Debian repository|GPL-3.0|
|[netcdf](https://octave.sourceforge.io/netcdf)| Debian repository|GPL-2.0|
|[The NaN-toolbox](https://octave.sourceforge.io/nan)| Debian repository|GPL-3.0|

## Utility Software
|Utility|Software Name |
|-------------|--------------|
|Desktop| preconfigured XFCE 4|
|Browser| Firefox|
|Office | LibreOffice|
|Text Editor| Mousepad|

## Help to build SARbian

If you want to help building SARbian you should have a look at the [developer manual](DEVEL.md)
and the [Live Systems Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/about-manual.en.html).

## License

The scripts we use for packaging and triggering live-build are free software
distributed under the terms of the GNU General Public License 3.0 or any later
version.

## Acknowledgement

We would like to thank the [Debian Project](https://debian.org) and the [Debian Live Project](https://wiki.debian.org/DebianLive).

SARbian is provided by the [EO College](https://eo-college.org) and was developed in the framework of the project SAR-EDU.

SAR-EDU is funded by the Federal Ministry of Economics and Technology, on the basis of a decision by the German Bundestag.

## Disclaimer

SARbian is not affiliated with Debian. Debian is a registered trademark owned by Software in the Public Interest, Inc.
