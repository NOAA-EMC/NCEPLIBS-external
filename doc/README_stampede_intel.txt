Setup instructions for TACC Stampede using Intel-18.0.2

module purge
#
module load libfabric/1.7.0
module load git/2.9.0
module load autotools/1.1
module load xalt/2.7.9
module load TACC
#
module load python2/2.7.15
module load intel/18.0.2
module load cmake/3.16.1
module load impi/18.0.2
module load pnetcdf/1.11.0
module load netcdf/4.6.2
module li

> Currently Loaded Modules:
>  1) pnetcdf/1.11.0   2) netcdf/4.6.2   3) libfabric/1.7.0   4) intel/18.0.2   5) impi/18.0.2   6) git/2.9.0   7) autotools/1.1   8) python2/2.7.15   9) cmake/3.16.1  10) xalt/2.7.9  11) TACC

export CC=icc
export FC=ifort
export CXX=icpc
export NETCDF=${TACC_NETCDF_DIR}
export HDF5_ROOT=/opt/apps/intel18/hdf5/1.10.4/x86_64

mkdir -p $WORK/NCEPLIBS-ufs-v1.0.0.beta03/src
# for this particular user, this corresponds to /work/06146/tg854455/stampede2/NCEPLIBS-ufs-v1.0.0.beta03/src

cd $WORK/NCEPLIBS-ufs-v1.0.0.beta03/src
git clone -b ufs-v1.0.0.beta03 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_MPI=OFF -DBUILD_PNG=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=$WORK/NCEPLIBS-ufs-v1.0.0.beta03 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd $WORK/NCEPLIBS-ufs-v1.0.0.beta03/src
git clone -b ufs-v1.0.0.beta03 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=$WORK/NCEPLIBS-ufs-v1.0.0.beta03 -DCMAKE_INSTALL_PREFIX=$WORK/NCEPLIBS-ufs-v1.0.0.beta03 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make install


How to build the model with those libraries installed:

module purge
#
module load libfabric/1.7.0
module load git/2.9.0
module load autotools/1.1
module load xalt/2.7.9
module load TACC
#
module load python2/2.7.15
module load intel/18.0.2
module load cmake/3.16.1
module load impi/18.0.2
module load pnetcdf/1.11.0
module load netcdf/4.6.2

export CC=icc
export FC=ifort
export CXX=icpc
export NETCDF=${TACC_NETCDF_DIR}

. /work/06146/tg854455/stampede2/NCEPLIBS-ufs-v1.0.0.beta03/bin/setenv_nceplibs.sh
export CMAKE_Platform=stampede.intel
./build.sh 2>&1 | tee build.log
