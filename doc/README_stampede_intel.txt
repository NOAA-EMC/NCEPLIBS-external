Setup instructions for TACC Stampede using Intel-18.0.2

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

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
module li

> Currently Loaded Modules:
>   1) libfabric/1.7.0   3) autotools/1.1   5) TACC           7) cmake/3.16.1   9) python3/3.7.0
>   2) git/2.24.1        4) xalt/2.8        6) intel/18.0.2   8) impi/18.0.2

export CC=icc
export CXX=icpc
export FC=ifort

# $WORK is set automatically by the system; for the user writing these instructions,
# it corresponds to /work/06146/tg854455/stampede2/NCEPLIBS-develop/src
export INSTALL_PREFIX=$WORK/NCEPLIBS-develop/src

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

export NETCDF=${INSTALL_PREFIX}
export ESMFMKFILE=${INSTALL_PREFIX}/lib64/esmf.mk
export WGRIB2_ROOT=${INSTALL_PREFIX}

cd ${INSTALL_PREFIX}/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DDEPLOY=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
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

export CC=icc
export FC=ifort
export CXX=icpc
export INSTALL_PREFIX=$WORK/NCEPLIBS-develop/src

module use -a ${INSTALL_PREFIX}/modules

module load netcdf/4.7.4
module load esmf/8.1.0bs21
module load wgrib2/2.0.8

module load bacio/2.4.0
module load nemsio/2.5.1
module load sp/2.3.0
module load w3emc/2.7.0
module load w3nco/2.4.0
module load nceppost/dceca26
module load sigio/2.3.0
module load g2/3.4.0
module load g2tmpl/1.9.0
module load ip/3.3.0
module load crtm/2.3.0

export CMAKE_Platform=stampede.intel
./build.sh 2>&1 | tee build.log
