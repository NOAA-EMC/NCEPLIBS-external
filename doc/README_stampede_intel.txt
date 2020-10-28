Setup instructions for TACC Stampede using Intel-18.0.2

module purge
#
module load libfabric/1.7.0
module load git/2.24.1
module load autotools/1.1
module load xalt/2.8
module load TACC
#
module load python3/3.7.0
module load intel/18.0.2
module load cmake/3.16.1
module load impi/18.0.2
module load pnetcdf/1.11.0
module load netcdf/4.6.2
module li

> Currently Loaded Modules:
>   1) libfabric/1.7.0   2) git/2.24.1   3) autotools/1.1   4) xalt/2.8   5) TACC   6) intel/18.0.2   7) cmake/3.16.1
>   8) impi/18.0.2   9) python3/3.7.0  10) pnetcdf/1.11.0  11) netcdf/4.6.2

export CC=icc
export CXX=icpc
export FC=ifort
export NETCDF=${TACC_NETCDF_DIR}
export HDF5_ROOT=/opt/apps/intel18/hdf5/1.10.4/x86_64

# DH* TEMPORARY - NEED SHARED LOCATION
export INSTALL_PREFIX=/work/06146/tg854455/stampede2/NCEPLIBS-ufs-v2.0.0/intel-18.0.2/impi-18.0.2
# *DH

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

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

git clone -b ufs-v2.0.0 --recursive https://github.com/ufs-community/ufs-weather-model

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.

module purge
module load libfabric/1.7.0
module load git/2.24.1
module load autotools/1.1
module load xalt/2.8
module load TACC

module load python3/3.7.0
module load intel/18.0.2
module load cmake/3.16.1
module load impi/18.0.2
module load pnetcdf/1.11.0
module load netcdf/4.6.2

module use /work/06146/tg854455/stampede2/NCEPLIBS-ufs-v2.0.0/intel-18.0.2/impi-18.0.2/modules
module load NCEPLIBS/2.0.0

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort
export CMAKE_Platform=stampede.intel
./build.sh 2>&1 | tee build.log
