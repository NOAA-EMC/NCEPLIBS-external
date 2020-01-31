# NCEPLIBS-external

## Warning

This documentation as well as the libraries are work in progress and currently undergoing rapid development. Do not expect any of this to work.

## Introduction

This is a compilation of third-party libraries required to build NCEPLIBS and by extension the UFS weather model. 

It inclues the following libraries:

1. NetCDF: netcdf-c-4.7.3, netcdf-fortran-4.5.2
2. ESMF: esmf-8.0.0
3. HDF5: hdf5-1.10.4
4. curl: curl-7.63.0
5. zlib: zlib-1.2.11
6. Jasper: jasper-2.0.16
7. libpng: libpng-1.6.35
8. libjpeg: jpeg-9.1
9. (optional) CMake: cmake-3.16.3

## Building

```
git clone https://github.com/NOAA-EMC/NCEPLIBS-external
cd NCEPLIBS-external
git submodule update --init --recursive
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=INSERT_PATH_HERE ..
make <-jx>
```
If `-DCMAKE_INSTALL_PREFIX=` is omitted, the libraries will be installed in directory `install` underneath the `build`` directory. The optional argument `<-jx>` speeds up the build process by using `x` parallel compile tasks.

## Requirements

1. CMake version 3.12 or newer. If the `cmake` command above fails because the existing CMake version is too old, you need to install a newer version. The NCEPLIBS-external code contains
`cmake-3.16.3` in subdirectory `cmake-src`. To install this version:
```
cd ../cmake-src # assuming you are still in the build directory
./bootstrap --prefix=INSERT_PATH_HERE
make
make install
cd ../build
rm -fr CMakeCache.txt CMakeFiles
```
For building NCEPLIBS-external, use `/full_path_to_where_you_installed_cmake/bin/cmake` instead of just `cmake`.

2. A supported C/C++ and Fortran compiler, see table below. Other versions may work, in particular if close to the versions listed below. If the chosen compiler is not the default compiler on the system, set the environment variables `export CC=...`, `export CXX=...`, `export FC=...`, before invoking `cmake`.

| Compiler vendor | Supported (tested) versions                                |
|-----------------|------------------------------------------------------------|
| Intel           | 18.0.3.222, 18.0.5.274, 19.0.2.187, 19.0.5.281             |
| GNU             | 8.3.0, 9.1.0, 9.2.0                                        |

3. A supported MPI library, see table below. Other versions may work, in particular if close to the versions listed below. It is recommended to compile the MPI library with the same compilers used to compile NCEPLIBS-external.

| MPI library     | Supported (tested) versions                                |
|-----------------|------------------------------------------------------------|
| MPICH           | 3.3.1, 3.3.2                                               |
| MVAPICH2        | 2.3.3                                                      |
| Open MPI        | 4.0.2                                                      |
| Intel MPI       | 2018.0.4, 2019.6.154                                       |
| SGI MPT         | 2.19                                                       |

## Troubleshooting

1. The cmake step reports an error that it cannot detect the MPI type. Only the MPI libraries listed above have been preconfigured for ESMF. Other libraries can be used by setting `-DMPITYPE=...` in the cmake call, provided that ESMF supports this library (currently supported by ESMF: mpi, mpt, mpich, mpich2, mpich3, mvapich2, intelmpi, lam - see ESMF documentation for details).

2. The build fails because of undefined symbols in any of the libraries. The most likely reason for this error is that cmake found a different version of the library on the system, for example installed by the Linux package manager or homebrew on macOS. While there is no single solution for this problem, the following options have been used successfully:
    - Remove the existing library, if possible (often it is not, because other software on the system depends on it)
    - Take the existing library out of the `PATH` and `LD_LIBRARY_PATH`, if possible (not always, because other software installed in the same location, may be needed)
    - Look inside NCEPLIBS-external's top-level `CMakeLists.txt` if the offending library is one of the build targets, and if yes, turn it off.
    - If the offending library is a prerequisite for a build target (i.e. HDF5 is a prerequisite for NetCDF) and the build target itself is already installed on the system, try to turn off the build target (e.g. `option(BUILD_NETCDF "Build NetCDF?" OFF)`)
    - If the offending library is a prerequisite for a build target (i.e. HDF5 is a prerequisite for NetCDF) and the build target itself is _not_ installed on the system, you need to install the build target using the same method you used for installing the offending library and turn it off in `CMakeLists.txt`.

## Support

MISSING

## Disclaimer

The United States Department of Commerce (DOC) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. DOC has relinquished control of the information and no longer has responsibility to protect the integrity, confidentiality, or availability of the information. Any claims against the Department of Commerce stemming from the use of its GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.

