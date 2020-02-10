#!/bin/bash

# Fix the wrong installation directories in zlib's CMakeLists.txt

file=$1
grep -e GNUInstallDirs $file >/dev/null
if [ $? -eq 0 ]; then
  exit 0
fi
sed -i -e 's#set(INSTALL_BIN_DIR#include(GNUInstallDirs)\'$'\nset(INSTALL_BIN_DIR#g' $1
sed -i -e 's#${CMAKE_INSTALL_PREFIX}/bin#${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}#g' $1
sed -i -e 's#${CMAKE_INSTALL_PREFIX}/lib#${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}#g' $1
sed -i -e 's#${CMAKE_INSTALL_PREFIX}/include#${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}#g' $1
sed -i -e 's#${CMAKE_INSTALL_PREFIX}/share#${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}#g' $1