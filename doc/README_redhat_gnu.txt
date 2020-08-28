### Red Hat Enterprise Linux 8.1 using gcc-9.2.1 and gfortran-9.2.1

NOTE: set "export INSTALL_PREFIX=..." as required for your installation (twice in this file!)

The following instructions were tested on a Red Hat 8 Amazon EC2 compute node, which comes with
essentially no packages installed. Many of the packages that are installed with yum in the
following may already be installed on your system. Note that the yum Open MPI library did not
work correctly in our tests, instead the NCEPLIBS-external MPICH version is used.

AMI: RHEL-8.2.0_HVM-20200423-x86_64-0-Hourly2-GP2 (ami-098f16afa9edf40be)

Instance: t2.xlarge instance with 4 cores and 16GB of memory was used, 100GB EBS

1. Install the GNU compilers and other utilities

sudo su
# Optional: this is usually a good idea, but should be used with care (it may destroy your existing setup)
yum update
# Install wget-1.19.5
yum install -y wget
# Install git-2.18.2
yum install -y git
# Install make-4.2.1
yum install -y make
# Install openssl-devel-1.1.1
yum install -y openssl-devel
# Install patch-2.7.6
yum install -y patch
# Install Python-3.8.0
yum install -y python38
alternatives --config python
# choose /usr/bin/python3
# Install libxml2-2.9.7 (for xmllint)
yum install libxml2
# Install m4-1.4.18
yum install m4
# Install gcc-9.2.1 - does this work w/o installing gcc-8.3.1 above?
yum install gcc-toolset-9-gcc-c++.x86_64 gcc-toolset-9-gcc-gfortran.x86_64

export INSTALL_PREFIX=/usr/local/ufs-develop

mkdir ${INSTALL_PREFIX}
chown -R ec2-user:ec2-user ${INSTALL_PREFIX}
exit

scl enable gcc-toolset-9 bash

export CC=gcc
export CXX=g++
export FC=gfortran

cd ${INSTALL_PREFIX}
mkdir src

2.Install missing external libraries from NCEPLIBS-external

The user is referred to the top-level README.md for more detailed instructions on how to build
NCEPLIBS-external and configure it (e.g., how to turn off building certain packages such as MPI etc).
The default configuration assumes that all dependencies are built and installed: MPI, netCDF, ...

cd ${INSTALL_PREFIX}/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
# Install cmake 3.16.3 (default OS version is too old)
cd cmake-src
./bootstrap --prefix=${INSTALL_PREFIX} 2>&1 | tee log.bootstrap
make 2>&1 | tee log.make
make install 2>&1 | tee log.install
cd ..
mkdir build && cd build
${INSTALL_PREFIX}/bin/cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make
# no make install needed


3. Install NCEPLIBS

The user is referred to the top-level README.md of the NCEPLIBS GitHub repository
(https://github.com/NOAA-EMC/NCEPLIBS/) for more detailed instructions on how to configure
and build NCEPLIBS. The default configuration assumes that all dependencies were built
by NCEPLIBS-external as described above.

cd ${INSTALL_PREFIX}/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build
cd build
${INSTALL_PREFIX}/bin/cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make
# no make install needed


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


scl enable gcc-toolset-9 bash
export CC=gcc
export CXX=g++
export FC=gfortran
ulimit -s unlimited
export INSTALL_PREFIX=/usr/local/ufs-develop
export PATH=${INSTALL_PREFIX}/bin:$PATH
export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:${INSTALL_PREFIX}/lib64:$PATH
export NETCDF=${INSTALL_PREFIX}
export ESMFMKFILE=${INSTALL_PREFIX}/lib64/esmf.mk
export CMAKE_Platform=linux.gnu
./build.sh 2>&1 | tee build.log
