Setup instructions for NOAA RDHPC Gaea using Cray Intel-18.0.3.222

module load intel/18.0.3.222
module unload cray-mpich/7.4.0
module load cray-mpich/7.7.3
module unload cray-netcdf
module use -a /lustre/f2/pdata/esrl/gsd/ufs/modules/modulefiles/generic
module load cmake/3.16.4
module li

> Currently Loaded Modulefiles:
>   1) modules/3.2.10.5                                7) udreg/2.3.2-6.0.6.0_15.18__g5196236.ari        13) job/2.2.3-6.0.6.0_9.47__g6c4e934.ari           19) craype-broadwell                               25) hpcrpt/noaa-3
>   2) eproxy/2.0.22-6.0.6.0_5.1__g1ebe45c.ari         8) ugni/6.0.14-6.0.6.0_18.12__g777707d.ari        14) dvs/2.7_2.2.96-6.0.6.1_10.6__g9b73f30          20) CmrsEnv                                        26) cmake/3.16.4
>   3) intel/18.0.3.222                                9) pmi/5.0.10-1.0000.11050.0.0.ari                15) alps/6.6.0-6.0.6.0_35.25__gd0a1ab9.ari         21) TimeZoneEDT                                    27) cray-mpich/7.7.3
>   4) craype-network-aries                           10) dmapp/7.1.1-6.0.6.0_51.37__g5a674e0.ari        16) rca/2.2.18-6.0.6.0_19.14__g2aa4f39.ari         22) globus_toolkit/6.0.1470089956
>   5) craype/2.5.5                                   11) gni-headers/5.0.12-6.0.6.0_3.26__g527b6e1.ari  17) atp/2.0.2                                      23) globus/6.0.1470089956
>   6) cray-libsci/16.06.1                            12) xpmem/2.2.14-6.0.6.1_5.8__g34333c9.ari         18) PrgEnv-intel/6.0.3                             24) DefApps

# Need to use MPI wrappers in order to find pre-installed Cray MPICH
export CC=cc
export FC=ftn
export CXX=CC
export MPI_ROOT=/opt/cray/pe/mpt/7.7.3/gni/mpich-intel/16.0

mkdir -p /lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0/intel-18.0.3.222/cray-mpich-7.7.3/src

cd /lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0/intel-18.0.3.222/cray-mpich-7.7.3/src
# Note: remote access severely limited on gaea; need to do the git clone on a remote system and rsync to gaea
git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DSTATIC_IS_DEFAULT=ON -DCMAKE_INSTALL_PREFIX=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0/intel-18.0.3.222/cray-mpich-7.7.3 .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
# no make install necessary

cd /lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0/intel-18.0.3.222/cray-mpich-7.7.3/src
# Note: remote access severely limited on gaea; need to do the git clone on a remote system and rsync to gaea
git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0/intel-18.0.3.222/cray-mpich-7.7.3 -DCMAKE_INSTALL_PREFIX=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0/intel-18.0.3.222/cray-mpich-7.7.3 -DSTATIC_IS_DEFAULT=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make install VERBOSE=1 2>&1 | tee log.install


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


module load intel/18.0.3.222
module unload cray-mpich/7.4.0
module load cray-mpich/7.7.3
module unload cray-netcdf

module use -a /lustre/f2/pdata/esrl/gsd/ufs/modules/modulefiles/generic
module load cmake/3.16.4

module use -a /lustre/f2/pdata/esrl/gsd/ufs/modules/modulefiles/intel-18.0.3.222
module load NCEPlibs/1.0.0

export CMAKE_Platform=gaea.intel
export CMAKE_C_COMPILER=cc
export CMAKE_CXX_COMPILER=CC
export CMAKE_Fortran_COMPILER=ftn

./build.sh 2>&1 | tee build.log
