# Dependencies

`mapnik` is required. On most platforms, a binary is installed with the `node-mapnik` module. However, this binary only supports a subset of the available GIS
data (e.g. databases and unusual raster formats not
supported). It is possible to dynamically link to
a systemwide installation of mapnik by using

> npm install mapnik --build-from-source

Mapnik can be installed with various package managers
(Homebrew, Apt) or as part of the OSGEO4W suite (on Mac).

## Rebuild for Electron

Rebuild node modules for version of python used.
