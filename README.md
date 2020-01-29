# NCEPLIBS-external

This is a compilation of third-party libraries required to build NCEPLIBS and by extension the UFS weather model. 


It inclues the following libraries:

1. NetCDF
2. ESMF
3. HDF5
4. curl
5. zlib
6. Jasper
7. libpng
8. libjpeg

# Building

```
cd NCEPLIBS-external
mkdir build
cd build
cmake .. -DBUILD_<ALL,MISSING>=true -DMPITYPE=<openmpi,intelmpi,mpt,etc>
make <-jx>
```

To build all libraries pass `-DBUILD_ALL=true` when invoking CMake

To build only libraries that can't be found pass the option: `-DBUILD_MISSING=true`

To manualy specify the libraries to build pass a comma separated list to the option`-DBUILD_LIBS=esmf,netcdf,jasper`

To set the MPI type (if building ESMF) pass `-DMPITYPE=<openmpi,intelmpi,mpt,etc>`
