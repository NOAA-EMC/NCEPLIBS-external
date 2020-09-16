####################################################################################################
# TODO: NEEDS UPDATE TO WORK WITH RELEASE/PUBLIC-V2 BRANCHES OF NCEPLIBS-EXTERNAL AND NCEPLIBS     #
####################################################################################################

Setup instructions for Intel Endeavor using Intel-19.1.2.254

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

export INSTALL_PREFIX=/global/panfs/users/Xdheinz/ufs-stack-20200803/intel-19.1.2/impi-2019.8.254
export PATH=${INSTALL_PREFIX}/bin:${PATH}

. /opt/intel/compiler/2020u2/bin/compilervars.sh intel64
. /opt/intel/impi/2019.8.254/bin/compilervars.sh intel64

export CC=icc
export CXX=icpc
export FC=ifort

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

# rsync NCEPLIBS-external from remote, no internet access on Endeavor
cd NCEPLIBS-external/
cd cmake-src/
./bootstrap --prefix=${INSTALL_PREFIX} 2>&1 | tee log.bootstrap
make 2>&1 | tee log.make
make install 2>&1 | tee log.install
cd ..
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

#####################################################################
# On another machine with access to GitHub, do:
cd NCEPLIBS
mkdir build && cd build
cmake -DDOWNLOAD_ONLY=ON .. 2>&1 | tee log.download
make 2>1 | tee log.make # this downloads the files only to ../download
cd ..
rm -fr build
cd ..
# rsync NCEPLIBS from this remote to Endeavor, then, on Endeavor, do:
#####################################################################

cd ${INSTALL_PREFIX}/src
cd NCEPLIBS
mkdir build && cd build
cmake -DUSE_LOCAL=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 2>&1 | tee log.make


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the UFS applications - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


export INSTALL_PREFIX=/global/panfs/users/Xdheinz/ufs-stack-20200803/intel-19.1.2/impi-2019.8.254
export PATH=${INSTALL_PREFIX}/bin:${PATH}

. /opt/intel/compiler/2020u2/bin/compilervars.sh intel64
. /opt/intel/impi/2019.8.254/bin/compilervars.sh intel64

export CC=icc
export CXX=icpc
export FC=ifort

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort

export NETCDF=${INSTALL_PREFIX}
export ESMFMKFILE=${INSTALL_PREFIX}/lib64/esmf.mk
export WGRIB2_ROOT=${INSTALL_PREFIX}

# DH note: for some reason, this suffices and the system finds all the NCEP libraries
./build.sh 2>&1 | tee build.log
