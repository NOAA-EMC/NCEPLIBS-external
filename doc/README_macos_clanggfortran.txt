##########################################################################################
# TODO: NEEDS UPDATE TO WORK WITH DEVELOP BRANCHES OF NCEPLIBS-EXTERNAL AND NCEPLIBS     #
##########################################################################################

Setup instructions for macOS Mojave or Catalina using clang-10.0.0 + gfortran-10.2.0

The following instructions were tested on a clean macOS systems (Mojave 10.14.6 and Catalina 10.15.6).
Homebrew is used to install the LLVM (clang+clang++) and GNU (gcc+gfortran) compilers. Note that the export statements
are required for the subsequent steps, as well as for building NCEPLIBS-external, NCEPLIBS and UFS applications.

Note that 16GB of memory are required for running the UFS weather model at C96 resolution.

1. Install homebrew, the LLVM/GNU compilers and other utilities

(1) Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

(1a) Mojave only: Install SDK headers
open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg

(2) Create directories
sudo su
mkdir /usr/local/ufs-release-v1.1.0
chown YOUR_USERNAME:YOUR_GROUPNAME /usr/local/ufs-release-v1.1.0
exit
cd /usr/local/ufs-release-v1.1.0
mkdir src

(3) Install gcc-10.2.0/gfortran-10.2.0

brew install gcc@10

(4) Install clang-10.0.0/clang++-10.0.0

brew install llvm@10

export PATH="/usr/local/opt/llvm/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/opt/llvm/lib:$LD_LIBRARY_PATH"

export CC=clang
export FC=gfortran
export CXX=clang++

(5) Install wget-1.20.3

brew install wget

(6) Install cmake-3.18.1

brew install cmake

(7) Install coreutils-8.32 (required later for running the UFS models)

brew install coreutils

(8) Install pkg-config-0.29.2

brew install pkg-config

2. Install missing external libraries from NCEPLIBS-external

The user is referred to the top-level README.md for more detailed instructions on how to build
NCEPLIBS-external and configure it (e.g., how to turn off building certain packages such as MPI etc).
The default configuration assumes that all dependencies are built and installed: MPI, netCDF, ...

cd /usr/local/ufs-release-v1.1.0/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ufs-release-v1.1.0 .. 2>&1 | tee log.cmake
make -j8 2>&1 | tee log.make
# no make install needed

3. Install NCEPLIBS

The user is referred to the top-level README.md of the NCEPLIBS GitHub repository
(https://github.com/NOAA-EMC/NCEPLIBS/) for more detailed instructions on how to configure
and build NCEPLIBS. The default configuration assumes that all dependencies were built
by NCEPLIBS-external as described above.

cd /usr/local/ufs-release-v1.1.0/src
git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS
cd NCEPLIBS
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ufs-release-v1.1.0 -DEXTERNAL_LIBS_DIR=/usr/local/ufs-release-v1.1.0 .. 2>&1 | tee log.cmake
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


export CC=clang-9
export FC=gfortran-9
export CXX=clang++-9
export PATH="/usr/local/opt/llvm/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/opt/llvm/lib:$LD_LIBRARY_PATH"
ulimit -S -s unlimited
. /usr/local/ufs-release-v1.1.0/bin/setenv_nceplibs.sh
export CMAKE_Platform=macosx.gnu
./build.sh 2>&1 | tee build.log

Note. OpenMP support is currently broken with the clang compiler. The UFS models should detect that
the clang compiler is used and turn off threading when building the model.

