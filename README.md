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
cmake .. <options>
make <-jx>
```

By default it will build all the libraries. However, the built libraries can be controlled in several ways by passing options to CMake through the command-line.

To build only libraries that can't be found pass the option: `-DBUILD_MISSING=true`

To manualy specify the libraries to build pass a comma separated list to the option`-DBUILD_LIBS=esmf,netcdf,jasper`
