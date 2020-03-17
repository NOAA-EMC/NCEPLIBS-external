### Red Hat Enterprise Linux 8.1 using gcc-8.3.1 and gfortran-8.3.1

The following instructions were tested on a Red Hat 8 Amazon EC2 compute node, which comes with
essentially no packages installed. Many of the packages that are installed with yum in the
following may already be installed on your system. Note that the yum Open MPI library did not
work correctly in our tests, instead the NCEPLIBS-external MPICH version is used.

A t3a.2xlarge instance with 16 cores and 32GB of memory was used, although a smaller instance
with 16GB of memory and fewer cores should suffice (need to adjust the number of parallel threads
for the make calls).

1. Install the GNU compilers and other utilities

sudo su
# Optional: this is usually a good idea, but should be used with care (it may destroy your existing setup)
yum update
# Install gcc-8.3.1, g++-8.3.1 and gfortran-8.3.1
yum install -y gcc-gfortran gcc-c++
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
# Install Python-2.7.16
yum install -y python2
alternatives --config python
# choose /usr/bin/python2
# Install libxml2-2.9.7 (for xmllint)
yum install libxml2-2.9.7

mkdir /usr/local/ufs-release-v1
chown -R ec2-user:ec2-user /usr/local/ufs-release-v1
exit

export CC=gcc
export CXX=g++
export FC=gfortran

cd /usr/local/ufs-release-v1
mkdir src

2.Install missing external libraries from NCEPLIBS-external

The user is referred to the top-level README.md for more detailed instructions on how to build
NCEPLIBS-external and configure it (e.g., how to turn off building certain packages such as MPI etc).
The default configuration assumes that all dependencies are built and installed: MPI, netCDF, ...

cd /usr/local/ufs-release-v1/src
git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
# Install cmake 3.16.3 (default OS version is too old)
cd cmake-src
./bootstrap --prefix=/usr/local/ufs-release-v1
make
make install
cd ..
mkdir build && cd build
/usr/local/ufs-release-v1/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ufs-release-v1 .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make


3. Install NCEPLIBS

The user is referred to the top-level README.md of the NCEPLIBS GitHub repository
(https://github.com/NOAA-EMC/NCEPLIBS/) for more detailed instructions on how to configure
and build NCEPLIBS. The default configuration assumes that all dependencies were built
by NCEPLIBS-external as described above.

cd /usr/local/ufs-release-v1/src
git clone -b ufs-v1.0.0 --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build
cd build
/usr/local/ufs-release-v1/bin/cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ufs-release-v1 -DEXTERNAL_LIBS_DIR=/usr/local/ufs-release-v1 .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make
make install 2>&1 | tee log.install


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.


export CC=gcc
export CXX=g++
export FC=gfortran
ulimit -s unlimited
. /usr/local/ufs-release-v1/bin/setenv_nceplibs.sh
export CMAKE_Platform=linux.gnu
./build.sh 2>&1 | tee build.log

