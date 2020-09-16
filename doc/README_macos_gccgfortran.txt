####################################################################################################
# TODO: NEEDS UPDATE TO WORK WITH RELEASE/PUBLIC-V2 BRANCHES OF NCEPLIBS-EXTERNAL AND NCEPLIBS     #
####################################################################################################

Setup instructions for macOS Mojave or Catalina using gcc-10.2.0 + gfortran-10.2.0

The following instructions were tested on a clean macOS systems (Mojave 1.14.6 and Catalina 10.15.2).
Homebrew is used to install the GNU (gcc+gfortran) compilers. Note that the export statements are
required for the subsequent steps, as well as for building NCEPLIBS-external, NCEPLIBS and UFS applications.

Note that 16GB of memory are required for running the UFS weather model at C96 resolution.

1. Install homebrew, the GNU compilers and other utilities:

(1) Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

(1a) Mojave only: Install SDK headers
open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg

(2) Create directories
sudo su
export INSTALL_PREFIX=/usr/local/NCEPLIBS-ufs-v2.0.0
mkdir ${INSTALL_PREFIX}
chown YOUR_USERNAME:YOUR_GROUPNAME ${INSTALL_PREFIX}
exit
export INSTALL_PREFIX=/usr/local/NCEPLIBS-ufs-v2.0.0
cd ${INSTALL_PREFIX}
mkdir src

(3) Install gcc-10.2.0/gfortran-10.2.0

brew install gcc@10

export CC=gcc-10
export FC=gfortran-10
export CXX=g++-10

(4) Install wget-1.20.3

brew install wget

(5) Install cmake-3.18.1

brew install cmake

(6) Install coreutils-8.32 (required later for running the UFS models)

brew install coreutils

(7) Install pkg-config-0.29.2

brew install pkg-config

2. Install missing external libraries from NCEPLIBS-external

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
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX} -DOPENMP=ON .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make


- END OF THE SETUP INSTRUCTIONS -


The following instructions are for building the ufs-weather-model (standalone;
not the ufs-mrweather app - for the latter, the model is built by the workflow)
with those libraries installed.

This is separate from NCEPLIBS-external and NCEPLIBS, and details on how to get
the code are provided here: https://github.com/ufs-community/ufs-weather-model/wiki

After checking out the code and changing to the top-level directory of ufs-weather-model,
the following commands should suffice to build the model.

export INSTALL_PREFIX=/usr/local/NCEPLIBS-ufs-v2.0.0

export CC=gcc-10
export FC=gfortran-10
export CXX=g++-10

ulimit -S -s unlimited

### DH* TODO - HOW ??? . ${INSTALL_PREFIX}/bin/setenv_nceplibs.sh

export CMAKE_Platform=macosx.gnu
./build.sh 2>&1 | tee build.log


