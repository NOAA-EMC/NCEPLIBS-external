Setup instructions for NOAA RDHPC Jet using Intel-18.0.5.274

module purge
module load intel/18.0.5.274
module load impi/2018.4.274
module load cmake/3.16.1
module li

> Currently Loaded Modules:
>  1) intel/18.0.5.274   2) impi/2018.4.274   3) cmake/3.16.1

export CC=icc
export CXX=icpc
export FC=ifort

export INSTALL_PREFIX=/lfs4/HFIP/hfv3gfs/software/NCEPLIBS-ufs-v2.0.0/intel-18.0.5.274/impi-2018.4.274

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
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
module load intel/18.0.5.274
module load impi/2018.4.274
module load cmake/3.16.1

module use /lfs4/HFIP/hfv3gfs/software/NCEPLIBS-ufs-v2.0.0/intel-18.0.5.274/impi-2018.4.274/modules

module load NCEPLIBS/2.0.0

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort
export CMAKE_Platform=jet.intel
./build.sh 2>&1 | tee build.log
