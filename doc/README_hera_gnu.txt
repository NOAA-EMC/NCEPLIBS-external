Setup instructions for NOAA RDHPC Hera using gnu-9.2.0

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

module purge
module load gnu/9.2.0
module use -a /scratch1/BMC/gmtb/software/modulefiles/gnu-9.2.0/mpich-3.3.2
module load mpich/3.3.2
module load cmake/3.16.1
module li

> Currently Loaded Modules:
>   1) gnu/9.2.0   2) mpich/3.3.2   3) cmake/3.16.1

export CC=gcc
export CXX=g++
export FC=gfortran
export INSTALL_PREFIX=/scratch1/BMC/gmtb/Dom.Heinzeller/ufs-srweather-app/NCEPLIBS-test-20200813-gnu

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
module load gnu/9.2.0
module use -a /scratch1/BMC/gmtb/software/modulefiles/gnu-9.2.0/mpich-3.3.2
module load mpich/3.3.2
module load cmake/3.16.1

export CC=gcc
export CXX=g++
export FC=gfortran
export INSTALL_PREFIX=/scratch1/BMC/gmtb/Dom.Heinzeller/ufs-srweather-app/NCEPLIBS-test-20200813-gnu

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

export CMAKE_Platform=hera.gnu
./build.sh 2>&1 | tee build.log
