#!/bin/bash

set -eux

CMAKE_INSTALL_PREFIX=$1

mkdir -p ${CMAKE_INSTALL_PREFIX}/include
mkdir -p ${CMAKE_INSTALL_PREFIX}/lib
cp lib/*.mod ${CMAKE_INSTALL_PREFIX}/include
cp lib/libwgrib2.a ${CMAKE_INSTALL_PREFIX}/lib
cp wgrib2/wgrib2 ${CMAKE_INSTALL_PREFIX}/bin
