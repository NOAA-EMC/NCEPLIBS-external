Setup instructions for NOAA WCOSS Cray machine using Intel-19.0.5.281

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

export INSTALL_PREFIX=/usrx/local/nceplibs/NCEPLIBS/NCEPLIBS-ufs-v2.0.0/intel-19.0.5.281/impi-2019

. /opt/modules/3.2.10.3/init/sh
module purge
module load PrgEnv-intel/5.2.82
module rm intel
module rm NetCDF-intel-sandybridge/4.2
module load intel/19.0.5.281
module load xt-lsfhpc/9.1.3
module load craype-sandybridge
module load cmake/3.16.2
module load git/2.18.0
module li

# Currently Loaded Modules:
# 1) craype-network-aries                   6) pmi/5.0.6-1.0000.10439.140.2.ari      11) alps/5.2.4-2.0502.9774.31.11.ari      16) intel/19.0.5.281
# 2) craype/2.3.0                           7) dmapp/7.0.1-1.0502.11080.8.76.ari     12) rca/1.0.0-2.0502.60530.1.62.ari       17) xt-lsfhpc/9.1.3
# 3) cray-libsci/13.0.3                     8) gni-headers/4.0-1.0502.10859.7.8.ari  13) atp/1.8.1                             18) craype-sandybridge
# 4) udreg/2.3.2-1.0502.10518.2.17.ari      9) xpmem/0.1-2.0502.64982.5.3.ari        14) PrgEnv-intel/5.2.82                   19) cmake/3.16.2
# 5) ugni/6.0-1.0502.10863.8.29.ari        10) dvs/2.5_0.9.0-1.0502.2188.1.116.ari   15) gcc/4.8.1                             20) git/2.18.0

export MPI_ROOT=/opt/cray/mpt/7.5.2/gni/mpich-intel/16.0/
export PNG_ROOT=/usrx/local/prod/png/1.2.49/intel/sandybridge

export CC=cc
export FC=ftn
export CXX=CC

export CMAKE_C_COMPILER=cc
export CMAKE_CXX_COMPILER=CC
export CMAKE_Fortran_COMPILER=ftn
export CMAKE_Platform=wcoss_cray

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8

cd ${INSTALL_PREFIX}/src
module use $INSTALL_PREFIX/modules
module load esmf jasper libpng libjpeg netcdf
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DOPENMP=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make deploy 2>&1 | tee log.deploy


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the UFS applications - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.

export INSTALL_PREFIX=/usrx/local/nceplibs/NCEPLIBS/NCEPLIBS-ufs-v2.0.0/intel-19.0.5.281/impi-2019

. /opt/modules/3.2.10.3/init/sh
module purge
module load PrgEnv-intel/5.2.82
module rm intel
module rm NetCDF-intel-sandybridge/4.2
module load intel/19.0.5.281
module load xt-lsfhpc/9.1.3
module load craype-sandybridge
module load python/2.7.14
module load cmake/3.16.2
module load git/2.18.0

module use ${INSTALL_PREFIX}/modules
module load NCEPLIBS/2.0.0
module load esmf jasper libpng libjpeg netcdf
module li

export CC=cc
export FC=ftn
export CXX=CC

export CMAKE_C_COMPILER=cc
export CMAKE_CXX_COMPILER=CC
export CMAKE_Fortran_COMPILER=ftn
export CMAKE_Platform=wcoss_cray

git clone -b ufs-v2.0.0 --recursive https://github.com/ufs-community/ufs-weather-model
cd ufs-weather-model

./build.sh 2>&1 | tee build.log
