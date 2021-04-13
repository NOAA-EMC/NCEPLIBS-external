Setup instructions for MSU Orion using Intel-19.1.0.166

NOTE: set "export INSTALL_PREFIX=..." as required for your installation

module purge
module load intel/2020
module load impi/2020
module load cmake/3.15.4
module li

> Currently Loaded Modules:
  1) intel/2020   2) munge/0.5.13   3) slurm/19.05.3-2   4) impi/2020   5) cmake/3.15.4

export CC=icc
export CXX=icpc
export FC=ifort
export INSTALL_PREFIX=/work/noaa/gmtb/dheinzel/NCEPLIBS-develop/intel-19.1.0.166/impi-2020.0.166

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

git clone -b ufs-v2.0.0 --recursive https://github.com/ufs-community/ufs-weather-model

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.

ulimit -s unlimited

module purge
module load intel/2020
module load impi/2020
module load cmake/3.15.4

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort
export INSTALL_PREFIX=/work/noaa/gmtb/dheinzel/NCEPLIBS-develop/intel-19.1.0.166/impi-2020.0.166

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

export CMAKE_Platform=orion.intel
./build.sh 2>&1 | tee build.log
