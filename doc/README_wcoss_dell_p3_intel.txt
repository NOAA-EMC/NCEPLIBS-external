Setup instructions for NOAA WCOSS DELL machine using Intel-18.0.1.163

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

export INSTALL_PREFIX=/usrx/local/nceplibs/dev/NCEPLIBS/cmake/install/NCEPLIBS

. /usrx/local/prod/lmod/lmod/init/sh
module purge
module load EnvVars/1.0.3
module load ips/18.0.1.163
module load impi/18.0.1
module load lsf/10.1
module load cmake/3.16.2
module li

# Currently Loaded Modules:
#    1) EnvVars/1.0.3   2) ips/18.0.1.163   3) impi/18.0.1   4) lsf/10.1   5) cmake/3.16.2

export CC=icc
export CXX=icpc
export FC=ifort

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort
export CMAKE_Platform=wcoss_dell_p3

export PNG_ROOT=/usrx/local/prod/packages/gnu/4.8.5/libpng/1.2.59

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8

cd ${INSTALL_PREFIX}/src
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
export ESMFMKFILE=${INSTALL_PREFIX}/lib64/esmf.mk
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

export INSTALL_PREFIX=/usrx/local/nceplibs/dev/NCEPLIBS/cmake/install/NCEPLIBS

git clone -b ufs-v2.0.0 --recursive https://github.com/ufs-community/ufs-weather-model
cd ufs-weather-model

. /usrx/local/prod/lmod/lmod/init/sh
module purge
module load EnvVars/1.0.3
module load ips/18.0.1.163
module load impi/18.0.1
module load lsf/10.1
module load cmake/3.16.2
module load python/2.7.14

module use ${INSTALL_PREFIX}/modules
module load NCEPLIBS/2.0.0

module use /gpfs/dell2/emc/modeling/noscrub/emc.nemspara/soft/modulefiles
module load hdf5_parallel/1.10.6
module load netcdf_parallel/4.7.4
module load esmf/8.0.0_ParallelNetCDF

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort
export CMAKE_Platform=wcoss_dell_p3

./build.sh 2>&1 | tee build.log
