### Ubuntu Linux 20.04 LTS using gcc-9.3.0 and gfortran-9.3.0

The following instructions were tested on a Ubuntu 20.04 Amazon EC2 compute node, which comes with
essentially no packages installed. Many of the packages that are installed with apt in the
following may already be installed on your system. Note that the apt Open MPI library did not
work correctly in our tests, instead the NCEPLIBS-external MPICH version is used.

AMI: ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20200729 (ami-0758470213bdd23b1)

Instance: t2.2xlarge instance with 8 cores and 32GB of memory was used, 100GB EBS

1. Install the GNU compilers and other utilities

sudo su
# Optional: this is usually a good idea, but should be used with care (it may destroy your existing setup)
apt update
# Install wget-1.20.3
apt install -y wget
# Install git-2.25.1
apt install -y git
# Install make-4.2.1
apt install -y make
# Install libssl-dev-1.1.1
apt install -y libssl-dev
# Install patch-2.7.6
apt install -y patch
# Configure Python 3.8 as default
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
# Install pip3-20.0.2
apt install python3-pip
# Install libxml2-utils-2.9.10 (for xmllint)
apt install -y libxml2-utils
# Install pkg-config-0.29.1
apt install -y pkg-config
# Install m4-1.4.18
apt install m4
# Install gcc-9.3.0, g++-9.3.0 and gfortran-9.3.0
apt install -y gfortran-9 g++-9
# Install cmake-3.16.3
apt install -y cmake
# Install unzip-6.0-25
apt install unzip
# Install geos-3.8.0
apt install libgeos-dev
# Install proj-6.3.1
apt install libproj-dev

export INSTALL_PREFIX=/usr/local/NCEPLIBS-ufs-v2.0.0

export INSTALL_PREFIX=/usr/local/ufs-develop

mkdir ${INSTALL_PREFIX}
chown -R ubuntu:ubuntu ${INSTALL_PREFIX}
exit

export CC=gcc-9
export CXX=g++-9
export FC=gfortran-9

cd ${INSTALL_PREFIX}
mkdir src

2.Install missing external libraries from NCEPLIBS-external

The user is referred to the top-level README.md for more detailed instructions on how to build
NCEPLIBS-external and configure it (e.g., how to turn off building certain packages such as MPI etc).
The default configuration assumes that all dependencies are built and installed: MPI, netCDF, ...

cd ${INSTALL_PREFIX}/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make


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
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make
make deploy 2>&1 | tee log.deploy


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the UFS applications - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

git clone -b ufs-v2.0.0 --recursive https://github.com/ufs-community/ufs-weather-model

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.

source /usr/local/NCEPLIBS-ufs-v2.0.0/bin/setenv_nceplibs.sh
ulimit -s unlimited
export INSTALL_PREFIX=/usr/local/ufs-develop
export PATH=${INSTALL_PREFIX}/bin:$PATH
export LD_LIBRARY_PATH=${INSTALL_PREFIX}/lib:$PATH
export NETCDF=${INSTALL_PREFIX}
export ESMFMKFILE=${INSTALL_PREFIX}/lib/esmf.mk
export CMAKE_Platform=linux.gnu
./build.sh 2>&1 | tee build.log


4. Install Python packages for the UFS SRW Application (regional workflow, plotting)

sudo su
pip3 install f90nml
pip3 install pyyaml
pip3 install jinja2
pip3 install pygrib
pip3 install cartopy
pip3 install matplotlib
pip3 install scipy
exit
