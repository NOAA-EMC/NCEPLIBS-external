Setup instructions for NSSL RDHPC Odin using Intel-19.0.5.281

module purge
module load slurm/19.05.3-2
module load craype/2.6.2
module load cray-mpich/7.7.10
module load craype-network-aries
module load cray-libsci/19.06.1
module load pmi/5.0.14
module load PrgEnv-intel/6.0.5
module swap intel/19.0.5.281
module load craype-ivybridge
module load cray-netcdf-hdf5parallel/4.6.3.2
module load cray-parallel-netcdf/1.11.1.1
module load cray-hdf5-parallel/1.10.5.2
module load gcc/8.3.0

> Currently Loaded Modulefiles:
>   1) slurm/19.05.3-2                    6) cray-libsci/19.06.1               11) craype-ivybridge
>   2) craype-network-aries               7) pmi/5.0.14                        12) cray-netcdf-hdf5parallel/4.6.3.2
>   3) craype/2.6.2                       8) atp/2.1.3                         13) cray-parallel-netcdf/1.11.1.1
>   4) cray-mpich/7.7.10                  9) perftools-base/7.1.1              14) cray-hdf5-parallel/1.10.5.2
>   5) intel/19.0.5.281                  10) PrgEnv-intel/6.0.5                15) gcc/8.3.0

export CC=cc
export FC=ftn
export CXX=cc
export SRC_DIR=/scratch/ywang/comFV3SAR/testings
export INSTALL_PREFIX=/scratch/ywang/comFV3SAR/testings/INSTALL
export CMAKE=/scratch/software/Odin/bin/cmake

mkdir -p $SRC_DIR
cd $SRC_DIR

git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
# If netCDF is not built, also don't build PNG, because netCDF uses the default (OS) zlib in the search path
$CMAKE -DBUILD_PNG=OFF -DBUILD_MPI=OFF -DBUILD_NETCDF=OFF -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DMPITYPE=mpi -DDEPLOY=ON .. 2>&1 | tee log.cmake
srun -n 1 make VERBOSE=1 -j8 2>&1 | tee log.make

cd $SRC_DIR
git clone -b ufs-v2.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build && cd build
$CMAKE -DEXTERNAL_LIBS_DIR=$INSTALL_PREFIX -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX -DOPENMP=ON -DDEPLOY=ON .. 2>&1 | tee log.cmake
make VERBOSE=1 -j8 2>&1 | tee log.make
make deploy 2>&1 | tee log.deploy
cd ..
# Convert lua modulefiles into tcl modulefiles
lua2tcl.py $INSTALL_PREFIX/modules


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the UFS applications - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

$> git clone -b develop --recursive https://github.com/ufs-community/ufs-weather-model

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


module purge
module load slurm/19.05.3-2
module load craype/2.6.2
module load cray-mpich/7.7.10
module load craype-network-aries
module load cray-libsci/19.06.1
module load pmi/5.0.14
module load PrgEnv-intel/6.0.5
module swap intel/19.0.5.281
module load craype-ivybridge
module load cray-netcdf-hdf5parallel/4.6.3.2
module load cray-parallel-netcdf/1.11.1.1
module load cray-hdf5-parallel/1.10.5.2
module load gcc/8.3.0

export NETCDF=${CRAY_NETCDF_DIR}
export CMAKE=/scratch/software/Odin/bin/cmake
export CC=cc
export FC=ftn
export CXX=cc

export CMAKE_C_COMPILER=cc
export CMAKE_CXX_COMPILER=CC
export CMAKE_Fortran_COMPILER=ftn

module use /scratch/ywang/comFV3SAR/testings/INSTALL/modules

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

# In file build.sh, change "cmake" to "$CMAKE" to use cmake version 3.17.3 in the system.

export CMAKE_Platform=odin.intel
./build.sh 2>&1 | tee build.log
