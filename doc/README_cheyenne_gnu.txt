Setup instructions for CISL Cheyenne using GNU-8.3.0

module purge
module load ncarenv/1.3
module load gnu/8.3.0
module load ncarcompilers/0.5.0
module load netcdf/4.7.3
module load mpt/2.19
module load cmake/3.16.4
module li

> Currently Loaded Modules:
>  1) ncarenv/1.3   2) gnu/8.3.0   3) ncarcompilers/0.5.0   4) netcdf/4.7.3   5) mpt/2.19   6) cmake/3.16.4

export CC=mpicc
export FC=mpif90
export CXX=mpicxx

mkdir -p /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v1.0.0/gnu-8.3.0/mpt-2.19/src
cd /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v1.0.0/gnu-8.3.0/mpt-2.19/src

git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DBUILD_PNG=OFF -DCMAKE_INSTALL_PREFIX=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v1.0.0/gnu-8.3.0/mpt-2.19 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j2 2>&1 | tee log.make

cd /glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v1.0.0/gnu-8.3.0/mpt-2.19/src
git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v1.0.0/gnu-8.3.0/mpt-2.19 -DCMAKE_INSTALL_PREFIX=/glade/p/ral/jntp/GMTB/tools/NCEPLIBS-ufs-v1.0.0/gnu-8.3.0/mpt-2.19 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j2 2>&1 | tee log.make
make install


How to build the model with those libraries installed:

module purge
module load ncarenv/1.3
module load gnu/8.3.0
module load ncarcompilers/0.5.0
module load netcdf/4.7.3
module load mpt/2.19
module load cmake/3.16.4

export CC=mpicc
export FC=mpif90
export CXX=mpicxx

module use -a /glade/p/ral/jntp/GMTB/tools/modulefiles/gnu-8.3.0/mpt-2.19
module load  NCEPlibs/1.0.0

export CMAKE_Platform=cheyenne.gnu
./build.sh 2>&1 | tee build.log
