#!/bin/bash

set -eux

SOURCE_DIR=$1

tar -xvzf $SOURCE_DIR/wgrib2-2.0.8.tar.gz

cd grib2

sed -i -e 's/^USE_NETCDF3=1/USE_NETCDF3=0/g' makefile
sed -i -e 's/^USE_IPOLATES=3/USE_IPOLATES=0/g' makefile
sed -i -e 's/^USE_OPENMP=1/USE_OPENMP=0/g' makefile
sed -i -e 's/^USE_AEC=1/USE_AEC=0/g' makefile
