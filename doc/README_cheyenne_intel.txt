Setup instructions for CISL Cheyenne using Intel-19.1.1

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

module purge
module load ncarenv/1.3
module load intel/19.1.1
module load mpt/2.19
module load ncarcompilers/0.5.0
module load cmake/3.16.4
module li

> Currently Loaded Modules:
>  1) ncarenv/1.3   2) intel/19.1.1   3) mpt/2.19   4) ncarcompilers/0.5.0   5) cmake/3.16.4

export CC=mpicc
export FC=mpif90
export CXX=mpicxx
export INSTALL_PREFIX=/glade/work/heinzell/fv3/ufs-srweather-app/NCEPLIBS-test-20200813-intel

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j2 2>&1 | tee log.make

export NETCDF=${INSTALL_PREFIX}
export ESMFMKFILE=${INSTALL_PREFIX}/lib64/esmf.mk
export WGRIB2_ROOT=${INSTALL_PREFIX}

cd ${INSTALL_PREFIX}/src/
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DDEPLOY=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make VERBOSE=1 -j2 2>&1 | tee log.make
make deploy 2>&1 | tee log.deploy


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


module purge
module load ncarenv/1.3
module load intel/19.1.1
module load mpt/2.19
module load ncarcompilers/0.5.0
module load cmake/3.16.4

export CC=mpicc
export FC=mpif90
export CXX=mpicxx
export INSTALL_PREFIX=/glade/work/heinzell/fv3/ufs-srweather-app/NCEPLIBS-test-20200813-intel

export NETCDF=${INSTALL_PREFIX}
export ESMFMKFILE=${INSTALL_PREFIX}/lib64/esmf.mk
export WGRIB2_ROOT=${INSTALL_PREFIX}

module use -a ${INSTALL_PREFIX}/modules
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

export CMAKE_Platform=cheyenne.intel
./build.sh 2>&1 | tee build.log
