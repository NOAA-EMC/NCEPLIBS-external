Setup instructions for CISL Cheyenne using GNU-9.1.0

NOTE: set "export INSTALL_PREFIX=..." as required for your installation (twice in this file!)

module purge
module load ncarenv/1.3
module load gnu/9.1.0
module load mpt/2.19
module load ncarcompilers/0.5.0
module load cmake/3.16.4
module li

> Currently Loaded Modules:
>  1) ncarenv/1.3   2) gnu/9.1.0   3) mpt/2.19   4) ncarcompilers/0.5.0   5) cmake/3.16.4

export CC=mpicc
export FC=mpif90
export CXX=mpicxx
export INSTALL_PREFIX=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-9.1.0/mpt-2.19

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DDEPLOY=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j2 2>&1 | tee log.make

cd ${INSTALL_PREFIX}/src
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DOPENMP=ON -DDEPLOY=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j2 2>&1 | tee log.make
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
module load ncarenv/1.3
module load gnu/9.1.0
module load mpt/2.19
module load ncarcompilers/0.5.0
module load cmake/3.16.4

export CC=mpicc
export FC=mpif90
export CXX=mpicxx

module use /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v2.0.0/gnu-9.1.0/mpt-2.19/modules

module load libpng/1.6.35
module load netcdf/4.7.4
module load esmf/8.0.0

module load bacio/2.4.1
module load crtm/2.3.0
module load g2/3.4.1
module load g2tmpl/1.9.1
module load ip/3.3.3
module load nceppost/dceca26
module load nemsio/2.5.2
module load sp/2.3.3
module load w3emc/2.7.3
module load w3nco/2.4.1

module load gfsio/1.4.1
module load sfcio/1.4.1
module load sigio/2.3.2

export CMAKE_Platform=cheyenne.gnu
./build.sh 2>&1 | tee build.log
