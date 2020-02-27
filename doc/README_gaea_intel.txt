Setup instructions for NOAA RDHPC Gaea using Cray Intel-18.0.3.222

module load intel/18.0.3.222
#module load cray-netcdf/4.4.0
module use -a /lustre/f2/pdata/esrl/gsd/ufs/modules/modulefiles/generic
module load cmake/3.16.4
module li

> Currently Loaded Modulefiles:
>   1) modules/3.2.10.5                                6) cray-libsci/16.06.1                            11) gni-headers/5.0.12-6.0.6.0_3.26__g527b6e1.ari  16) rca/2.2.18-6.0.6.0_19.14__g2aa4f39.ari         21) CmrsEnv                                        26) hpcrpt/noaa-3
>   2) eproxy/2.0.22-6.0.6.0_5.1__g1ebe45c.ari         7) udreg/2.3.2-6.0.6.0_15.18__g5196236.ari        12) xpmem/2.2.14-6.0.6.1_5.8__g34333c9.ari         17) atp/2.0.2                                      22) TimeZoneEDT                                    27) cray-netcdf/4.6.1.3
>   3) intel/18.0.3.222                                8) ugni/6.0.14-6.0.6.0_18.12__g777707d.ari        13) job/2.2.3-6.0.6.0_9.47__g6c4e934.ari           18) PrgEnv-intel/6.0.3                             23) globus_toolkit/6.0.1470089956                  28) cmake/3.16.4
>   4) craype-network-aries                            9) pmi/5.0.10-1.0000.11050.0.0.ari                14) dvs/2.7_2.2.96-6.0.6.1_10.6__g9b73f30          19) craype-broadwell                               24) globus/6.0.1470089956                          29) cray-netcdf/4.4.0
>   5) craype/2.5.5                                   10) dmapp/7.1.1-6.0.6.0_51.37__g5a674e0.ari        15) alps/6.6.0-6.0.6.0_35.25__gd0a1ab9.ari         20) cray-mpich/7.4.0                               25) DefApps

# Need to use MPI wrappers in order to find pre-installed Cray MPICH
export CC=cc
export FC=ftn
export CXX=CC
#export HDF5_ROOT=/opt/cray/pe/hdf5/1.8.16/INTEL/15.0
export MPI_ROOT=/opt/cray/pe/mpt/7.4.0/gni/mpich-intel/15.0
#export NETCDF=$NETCDF_DIR

mkdir -p /lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0/src

cd /lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0/src
# Note: remote access severely limited on gaea; need to do the git clone on a remote system and rsync to gaea
git clone -b ufs-v1.0.0.beta03 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
mkdir build && cd build
cmake -DBUILD_MPI=OFF -DSTATIC_IS_DEFAULT=ON -DCMAKE_INSTALL_PREFIX=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0 .. 2>&1 | tee log.cmake
#cmake -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0 .. 2>&1 | tee log.cmake
make VERBOSE=1 2>&1 | tee log.make
# no make install necessary

cd /lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0/src
# Note: remote access severely limited on gaea; need to do the git clone on a remote system and rsync to gaea
git clone -b ufs-v1.0.0.beta03 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
cmake -DEXTERNAL_LIBS_DIR=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0 -DCMAKE_INSTALL_PREFIX=/lustre/f2/pdata/esrl/gsd/ufs/modules/NCEPlibs-ufs-v1.0.0.beta03/intel-18.0.3.222/cray-mpich-7.4.0 -DSTATIC_IS_DEFAULT=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 2>&1 | tee log.make
make install VERBOSE=1 2>&1 | tee log.install


How to build the model with those libraries installed:

module load intel/18.0.3.222
module load cray-netcdf/4.4.0

module use -a /lustre/f2/pdata/esrl/gsd/ufs/modules/modulefiles/generic
module load cmake/3.16.4

module use -a /lustre/f2/pdata/esrl/gsd/ufs/modules/modulefiles/intel-18.0.3.222
module load NCEPlibs/1.0.0.beta03

#export NETCDF=$NETCDF_DIR
export CMAKE_Platform=gaea.intel
export CMAKE_C_COMPILER=cc
export CMAKE_CXX_COMPILER=CC
export CMAKE_Fortran_COMPILER=ftn

./build.sh 2>&1 | tee build.log
