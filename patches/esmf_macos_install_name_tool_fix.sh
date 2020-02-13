#!/bin/bash

# Fix for ESMF on macOS: correct library IDs in ESMF libraries, and paths to ESMF libraries in ESMF binaries

INSTALL_BINDIR=$1
INSTALL_LIBDIR=$2

# Fix wrong name (id) of ESMF libraries
cd $INSTALL_LIBDIR
for lib in libesmf*.dylib*
do
  libesmf_id_new=${INSTALL_LIBDIR}/${lib}
  echo "Fixing library id in ${lib}: set to ${libesmf_id_new}"
  install_name_tool -id ${libesmf_id_new} ${lib}
done

# Fix wrong path to ESMF libraries in ESMF binaries
cd $INSTALL_BINDIR
for exe in ESMF_*
do
  libesmf_path_old=(`otool -L $exe | grep libesmf`)
  libesmf_name=${libesmf_path_old##*/}
  libesmf_path_new=${INSTALL_LIBDIR}/${libesmf_name}
  echo "Fixing path to ${libesmf_name} in ${exe}: ${libesmf_path_old} --> ${libesmf_path_new}"
  install_name_tool -change ${libesmf_path_old} ${libesmf_path_new} ${exe}
done