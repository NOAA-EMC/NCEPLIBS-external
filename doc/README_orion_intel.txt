Setup instructions for MSU Orion using Intel-18.0.5.274

module purge
module load intel/2018.4
module load impi/2018.4
module load netcdf/4.7.2
module load cmake/3.15.4
module li

> Currently Loaded Modules:
  1) munge/0.5.13   2) slurm/19.05.3-2   3) impi/2018.4   4) intel/2018.4   5) hdf5/1.10.5   6) netcdf/4.7.2   7) cmake/3.15.4

# Note: HDF5 is in: /apps/hdf5/1.10.5/intel/18.0.5.274
# Note: ZLIB and PNG are in: /usr/include, /usr/lib64/

export CC=icc
export CXX=icpc
export FC=ifort

export HDF5_ROOT=/apps/intel-2020/hdf5-1.10.5
export PNG_ROOT=/usr

# Set environment variable WORK to a directory in your userspace, example for user dheinzel of group gmtb:
#export WORK=/work/noaa/gmtb/dheinzel

mkdir -p $WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274/src
cd $WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274/src

git clone -b ufs-v1.1.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=$WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd $WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274/src
git clone -b ufs-v1.1.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=$WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274 -DCMAKE_INSTALL_PREFIX=$WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274 .. 2>&1 | tee log.cmake
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
module load intel/2018.4
module load impi/2018.4
module load netcdf/4.7.2
module load cmake/3.15.4
module li

ulimit -s unlimited

export CMAKE_C_COMPILER=mpiicc
export CMAKE_CXX_COMPILER=mpiicpc
export CMAKE_Fortran_COMPILER=mpiifort

. $WORK/NCEPLIBS-ufs-v1.1.0/intel-18.0.5.274/impi-2018.5.274/bin/setenv_nceplibs.sh
export CMAKE_Platform=orion.intel
cp cmake/configure_hera.intel.cmake cmake/configure_orion.intel.cmake
./build.sh 2>&1 | tee build.log
