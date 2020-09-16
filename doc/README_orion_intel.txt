Setup instructions for MSU Orion using Intel-19.1.0.166

module purge
module load intel/2020
module load impi/2020
module load netcdf/4.7.2
module load cmake/3.15.4
module li

> Currently Loaded Modules:
  1) intel/2020   2) munge/0.5.13   3) slurm/19.05.3-2   4) impi/2020   5) hdf5/1.10.5   6) netcdf/4.7.2   7) cmake/3.15.4

# Note: HDF5 is in: /apps/hdf5/1.10.5/intel/18.0.5.274
# Note: ZLIB and PNG are in: /usr/include, /usr/lib64/

export CC=icc
export CXX=icpc
export FC=ifort

export HDF5_ROOT=/apps/intel-2020/hdf5-1.10.5
export PNG_ROOT=/usr

# DH* TEMPORARY - NEED SHARED LOCATION
export INSTALL_PREFIX=/work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v2.0.0/intel-19.1.0.166/impi-2020.0.166
# *DH

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DDEPLOY=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd ${INSTALL_PREFIX}/src
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DDEPLOY=ON -DOPENMP=ON .. 2>&1 | tee log.cmake
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

ulimit -s unlimited

module purge
module load intel/2020
module load impi/2020
module load netcdf/4.7.2
module load cmake/3.15.4

export CC=icc
export CXX=icpc
export FC=ifort

module use /work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v2.0.0/intel-19.1.0.166/impi-2020.0.166/modules

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

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort
export CMAKE_Platform=orion.intel
./build.sh 2>&1 | tee build.log
