Setup instructions for MSU Orion using Intel-19.1.0.166

module purge
module load intel/2020
module load impi/2020
module load netcdf/4.7.2
module load cmake/3.15.4
module li

> Currently Loaded Modules:
>  1) intel/18.0.5.274   2) impi/2018.0.4   3) netcdf/4.7.0   4) cmake/3.16.3

# Note: HDF5 is in: /apps/hdf5/1.10.5/intel/18.0.5.274
# Note: ZLIB and PNG are in: /usr/include, /usr/lib64/

export CC=icc
export CXX=icpc
export FC=ifort

export HDF5_ROOT=/apps/intel-2020/hdf5-1.10.5
export PNG_ROOT=/usr

mkdir -p /work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166/src
cd /work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166/src

git clone -b ufs-v1.0.0.beta04 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=/work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd /work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166/src
git clone -b ufs-v1.0.0.beta04 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=/work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166 -DCMAKE_INSTALL_PREFIX=/work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make install


How to build the model with those libraries installed:

module purge
module load intel/2020
module load impi/2020
module load netcdf/4.7.2
module load cmake/3.15.4
module li

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort

. /work/noaa/gmtb/dheinzel/NCEPLIBS-ufs-v1.0.0.beta04/intel-19.1.0.166/impi-2020.0.166/bin/setenv_nceplibs.sh
export CMAKE_Platform=orion.intel
cp cmake/configure_hera.intel.cmake cmake/configure_orion.intel.cmake
./build.sh 2>&1 | tee build.log
