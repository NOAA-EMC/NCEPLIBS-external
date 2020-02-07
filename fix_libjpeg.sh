#!/bin/bash

# Fix the wrong installation directories in libjpeg's CMakeLists.txt

file=$1
grep -e GNUInstallDirs $file >/dev/null
if [ $? -eq 0 ]; then
  exit 0
fi
sed -i -e 's/# Primary paths/# Primary paths\'$'\ninclude(GNUInstallDirs)/g' $1
sed -i -e 's/set ( INSTALL_BIN bin/set ( INSTALL_BIN ${CMAKE_INSTALL_BINDIR}/g' $1
sed -i -e 's/set ( INSTALL_LIB lib/set ( INSTALL_LIB ${CMAKE_INSTALL_LIBDIR}/g' $1
sed -i -e 's/set ( INSTALL_INC include/set ( INSTALL_INC ${CMAKE_INSTALL_INCLUDEDIR}/g' $1
sed -i -e 's/set ( INSTALL_ETC etc/set ( INSTALL_ETC ${CMAKE_SYSCONFDIR}/g' $1
sed -i -e 's/set ( INSTALL_SHARE share/set ( INSTALL_SHARE ${CMAKE_INSTALL_DATAROOTDIR}/g' $1