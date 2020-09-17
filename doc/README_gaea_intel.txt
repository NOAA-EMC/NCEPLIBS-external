Setup instructions for NOAA RDHPC Gaea using Cray Intel-19.0.5.281

module load intel/19.0.5.281
module unload cray-mpich
module load cray-mpich/7.7.11
module unload cray-netcdf
module load cmake/3.17.0
module li

> Currently Loaded Modulefiles:
>  1) modules/3.2.11.4                                 7) udreg/2.3.2-7.0.2.1_2.15__g8175d3d.ari          13) job/2.2.4-7.0.2.1_2.18__g36b56f4.ari            19) PrgEnv-intel/6.0.5                              25) DefApps
>  2) eproxy/2.0.24-7.0.2.1_2.20__g8e04b33.ari         8) ugni/6.0.14.0-7.0.2.1_3.15__ge78e5b0.ari        14) dvs/2.12_2.2.164-7.0.2.1_3.8__g1afc88eb         20) craype-broadwell                                26) hpcrpt/noaa-3
>  3) intel/19.0.5.281                                 9) pmi/5.0.15                                      15) alps/6.6.59-7.0.2.1_3.7__g872a8d62.ari          21) CmrsEnv                                         27) cray-mpich/7.7.11
>  4) craype-network-aries                            10) dmapp/7.1.1-7.0.2.1_2.19__g38cf134.ari          16) rca/2.2.20-7.0.2.1_2.20__g8e3fb5b.ari           22) TimeZoneEDT                                     28) cmake/3.17.0
>  5) craype/2.6.3                                    11) gni-headers/5.0.12.0-7.0.2.1_2.4__g3b1768f.ari  17) atp/2.1.3                                       23) globus-toolkit/6.0.17
>  6) cray-libsci/19.06.1                             12) xpmem/2.2.20-7.0.2.1_2.15__g87eb960.ari         18) perftools-base/7.1.3                            24) darshan/3.2.1

# Need to use MPI wrappers in order to find pre-installed Cray MPICH
export CC=cc
export FC=ftn
export CXX=CC
export MPI_ROOT=/opt/cray/pe/mpt/7.7.11/gni/mpich-intel/16.0

export INSTALL_PREFIX=/lustre/f2/pdata/esrl/gsd/ufs/NCEPLIBS-ufs-v2.0.0/intel-18.0.6.288/cray-mpich-7.7.11

mkdir -p ${INSTALL_PREFIX}/src
cd ${INSTALL_PREFIX}/src

# Note: remote access severely limited on gaea; need to do the git clone on a remote system and rsync to gaea
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DDEPLOY=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make

cd ${INSTALL_PREFIX}/src
# Note: remote access severely limited on gaea; need to do the git clone on a remote system and rsync to gaea;
# for NCEPLIBS, this requires a few more steps:
# on a machine with internet access, do:
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir tmp && cd tmp
cmake -DDOWNLOAD_ONLY=ON .. 2>&1 | tee log.cmake
make 2>&1 | tee log.make
cd ..
rm -fr tmp
# then rsync the entire NCEPLIBS folder to gaea ${INSTALL_PREFIX}/src/NCEPLIBS/
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
# Tell CMake to use the previously downloaded packages
cmake -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DDEPLOY=ON -DOPENMP=ON -DUSE_LOCAL=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make deploy 2>&1 | tee log.deploy
cd ..
# Convert lua modulefiles into tcl modulefiles
./lua2tcl.py ${INSTALL_PREFIX}/modules


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the UFS applications - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.

module load intel/19.0.5.281
module unload cray-mpich
module load cray-mpich/7.7.11
module unload cray-netcdf
module load cmake/3.17.0

export CC=cc
export FC=ftn
export CXX=CC

module use /lustre/f2/pdata/esrl/gsd/ufs/NCEPLIBS-ufs-v2.0.0/intel-18.0.6.288/cray-mpich-7.7.11/modules

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

export CMAKE_C_COMPILER=cc
export CMAKE_CXX_COMPILER=CC
export CMAKE_Fortran_COMPILER=ftn
export CMAKE_Platform=gaea.intel
./build.sh 2>&1 | tee build.log
