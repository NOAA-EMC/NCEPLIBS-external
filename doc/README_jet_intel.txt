##########################################################################################
# TODO: NEEDS UPDATE TO WORK WITH DEVELOP BRANCHES OF NCEPLIBS-EXTERNAL AND NCEPLIBS     #
##########################################################################################

Setup instructions for NOAA RDHPC Jet using Intel-18.0.5.274

module purge
module load intel/18.0.5.274
module load impi/2018.4.274
module load netcdf/4.7.0
module load cmake/3.16.1
module li

> Currently Loaded Modules:
>  1) intel/18.0.5.274   2) impi/2018.4.274   3) netcdf/4.7.0   4) cmake/3.16.1

export CC=icc
export FC=ifort
export CXX=icpc

# HDF5 is in: /apps/hdf5/1.10.5/intel/18.0.5.274
# ZLIB and PNG are in: /usr/include, /usr/lib64

export HDF5_ROOT=/apps/hdf5/1.10.5/intel/18.0.5.274
export PNG_ROOT=/usr

mkdir -p /lfs4/HFIP/hfv3gfs/software/NCEPlibs-develop/intel-18.0.5.274/impi-2018.4.274/src
cd /lfs4/HFIP/hfv3gfs/software/NCEPlibs-develop/intel-18.0.5.274/impi-2018.4.274/src

git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
cmake -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=/lfs4/HFIP/hfv3gfs/software/NCEPlibs-develop/intel-18.0.5.274/impi-2018.4.274 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd /lfs4/HFIP/hfv3gfs/software/NCEPlibs-develop/intel-18.0.5.274/impi-2018.4.274/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=/lfs4/HFIP/hfv3gfs/software/NCEPlibs-develop/intel-18.0.5.274/impi-2018.4.274 -DCMAKE_INSTALL_PREFIX=/lfs4/HFIP/hfv3gfs/software/NCEPlibs-develop/intel-18.0.5.274/impi-2018.4.274 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make install


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


module purge
module load intel/18.0.5.274
module load impi/2018.4.274
module load netcdf/4.7.0
module load cmake/3.16.1

export CC=icc
export FC=ifort
export CXX=icpc

module use -a /lfs4/HFIP/hfv3gfs/software/modulefiles/intel-18.0.5.274/impi-2018.4.274
module load NCEPlibs/1.1.0

export CMAKE_Platform=jet.intel
./build.sh 2>&1 | tee build.log
