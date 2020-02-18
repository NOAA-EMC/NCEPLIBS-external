#!/bin/bash

set -eux

CMAKE_INSTALL_PREFIX=$1
CMAKE_INSTALL_LIBDIR=$2

# Executable only built on some systems
WGRIB2EXE=wgrib2/wgrib2
if [ -f "${WGRIB2EXE}" ]; then
  mkdir -p ${CMAKE_INSTALL_PREFIX}/bin
  cp ${WGRIB2EXE} ${CMAKE_INSTALL_PREFIX}/bin
fi
# Libraries are always built
mkdir -p ${CMAKE_INSTALL_PREFIX}/include
mkdir -p ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
cp lib/*.mod ${CMAKE_INSTALL_PREFIX}/include
cp lib/libwgrib2.a ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
