Setup instructions for NOAA RDHPC Hera using Intel-18.0.5.274

module purge
module load gnu/9.2.0
module use -a /scratch1/BMC/gmtb/software/modulefiles/gnu-9.2.0/mpich-3.3.2
module load mpich/3.3.2
module load cmake/3.16.1

> Currently Loaded Modules:
>   1) gnu/9.2.0   2) mpich/3.3.2   3) cmake/3.16.1

export CC=gcc
export CXX=g++
export FC=gfortran

mkdir -p /scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v1.0.0/gnu-9.2.0/mpich-3.3.2/src
cd /scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v1.0.0/gnu-9.2.0/mpich-3.3.2/src

git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=/scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v1.0.0/gnu-9.2.0/mpich-3.3.2 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd /scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v1.0.0/gnu-9.2.0/mpich-3.3.2/src
git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
rm -fr build && mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=/scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v1.0.0/gnu-9.2.0/mpich-3.3.2 -DCMAKE_INSTALL_PREFIX=/scratch1/BMC/gmtb/software/NCEPLIBS-ufs-v1.0.0/gnu-9.2.0/mpich-3.3.2 .. 2>&1 | tee log.cmake
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
module load gnu/9.2.0
module use -a /scratch1/BMC/gmtb/software/modulefiles/gnu-9.2.0/mpich-3.3.2
module load mpich/3.3.2
module load cmake/3.16.1
module li

export CC=gcc
export CXX=g++
export FC=gfortran

module load  NCEPlibs/1.0.0

export CMAKE_Platform=hera.intel
./build.sh 2>&1 | tee build.log
