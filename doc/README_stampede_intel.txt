####################################################################################################
# TODO: NEEDS UPDATE TO WORK WITH RELEASE/PUBLIC-V2 BRANCHES OF NCEPLIBS-EXTERNAL AND NCEPLIBS     #
####################################################################################################

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
>   1) libfabric/1.7.0   3) autotools/1.1   5) TACC           7) cmake/3.16.1   9) python3/3.7.0   11) netcdf/4.6.2
>   2) git/2.24.1        4) xalt/2.8        6) intel/18.0.2   8) impi/18.0.2   10) pnetcdf/1.11.0

export CC=icc
export FC=ifort
export CXX=icpc
export NETCDF=${TACC_NETCDF_DIR}
export HDF5_ROOT=/opt/apps/intel18/hdf5/1.10.4/x86_64

mkdir -p $WORK/NCEPLIBS-develop/src
# $WORK is set automatically by the system; for the user writing these instructions,
# it corresponds to /work/06146/tg854455/stampede2/NCEPLIBS-develop/src

cd $WORK/NCEPLIBS-develop/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_MPI=OFF -DBUILD_PNG=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=$WORK/NCEPLIBS-develop .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd $WORK/NCEPLIBS-develop/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=$WORK/NCEPLIBS-develop -DCMAKE_INSTALL_PREFIX=$WORK/NCEPLIBS-develop .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make install 2>&1 | tee log.install


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


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

export CC=icc
export FC=ifort
export CXX=icpc
export NETCDF=${TACC_NETCDF_DIR}

. $WORK/NCEPLIBS-develop/bin/setenv_nceplibs.sh
export CMAKE_Platform=stampede.intel
./build.sh 2>&1 | tee build.log
