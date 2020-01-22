cmake_minimum_required(VERSION 3.16)
enable_language(Fortran)

project(NCEPLIBS-external)

option(BUILD_ALL "Build all libraries and don't search for system libraries" true)
option(BUILD_MISSING "Build only the libraries that can't be found" false)

option(BUILD_ESMF "Build ESMF?" false)
option(BUILD_NETCDF "Build NetCDF?" false)
option(BUILD_JASPER "Build Jasper?" false)
option(BUILD_PNG "Build libpng?" false)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/CMakeModules/Modules/")

if(DEFINED BUILD_LIBS)
  set(BUILD_ALL false)
  set(BUILD_MISSING false)
  # Make a CMake list out of comma-separated values and make them uppercase
  string(REPLACE "," ";" libs_to_build "${BUILD_LIBS}")
  string(TOUPPER "${libs_to_build}" libs_to_build)
  foreach(lib ${libs_to_build})
    if(DEFINED ${BUILD_${lib}})
      set(${BUILD_${lib}} true)
    endif()
  endforeach()  
endif()

if(BUILD_ALL)
  set(BUILD_NETCDF true)
  set(BUILD_ESMF true)
  set(BUILD_JASPER true)
  set(BUILD_PNG true)
endif()

if(BUILD_MISSING)
  find_package(NetCDF)
  find_package(ESMF)
  find_package(Jasper)
  find_package(PNG)

  if(NOT NETCDF_FOUND)
    set(BUILD_NETCDF true)
  endif()

  if(NOT ESMF_FOUND)
      set(BUILD_ESMF true)
  endif()

  if(NOT JASPER_FOUND)
    set(BUILD_JASPER true)
  endif()

  if(NOT PNG_FOUND)
    set(BUILD_PNG true)
  endif()
endif()


 if(NOT DEFINED MPITYPE AND BUILD_ESMF)
   message("Error: Building ESMF and MPITYPE is not set.")
   message("Valid options are: intelmpi, openmpi, mpich, mpich2, lam")
   message(FATAL_ERROR "To set on the command line use `cmake .. <options> -DMPITYPE=openmpi`")
 endif()

find_package(MPI REQUIRED)
set(install_path ${CMAKE_INSTALL_PREFIX}/third-party)

include(ExternalProject)

if(BUILD_NETCDF OR BUILD_PNG)
  ExternalProject_Add(zlib
    PREFIX ${PROJECT_BINARY_DIR}/zlib  
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/zlib  
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    )
endif()

if(BUILD_NETCDF)
  ExternalProject_Add(curl  
    PREFIX ${PROJECT_BINARY_DIR}/curl  
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/third-party
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_USE_OPENSSL=False
    -DHTTP_ONLY=True
    -DCMAKE_BUILD_TYPE=RELEASE
    -DCURL_CA_BUNDLE=none
    -DCURL_CA_PATH=none
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/curl  
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    )

  ExternalProject_Add(hdf5
    PREFIX ${PROJECT_BINARY_DIR}/hdf5
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/third-party
    -DCMAKE_CXX_COMPILER=${MPI_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${MPI_C_COMPILER}
    -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
    -DHDF5_BUILD_FORTRAN:BOOL=ON
    -DHDF5_BUILD_HL_LIB:BOOL=ON
    -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
    -DHDF5_ENABLE_SZIP_SUPPORT:BOOL=OFF
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/hdf5
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    )

  ExternalProject_Add(netcdf  
    PREFIX ${PROJECT_BINARY_DIR}/netcdf
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/third-party
    -DCMAKE_CXX_COMPILER=${MPI_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${MPI_C_COMPILER}
    -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
    -DHDF5_DIR=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/netcdf-c    
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS hdf5
    DEPENDS curl
    DEPENDS zlib
    )

  ExternalProject_Add(netcdf-fortran  
    PREFIX ${PROJECT_BINARY_DIR}/netcdf-fortran
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/third-party
    -DCMAKE_CXX_COMPILER=${MPI_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${MPI_C_COMPILER}
    -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
    -DnetCDF_INCLUDE_DIR=${CMAKE_INSTALL_PREFIX}/include
    -DENABLE_TESTS=OFF
    -DnetCDF_LIBRARIES=${NETCDF_LIBRARIES}
    -DHDF5_DIR=${HDF5_DIR}
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/netcdf-fortran    
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS netcdf
    )
endif()


if(BUILD_PNG)
  ExternalProject_Add(libpng
    PREFIX ${PROJECT_BINARY_DIR}/libpng
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/third-party
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libpng
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS zlib
    )
endif()


if(BUILD_JASPER)
  ExternalProject_Add(jasper
    PREFIX ${PROJECT_BINARY_DIR}/jasper
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/third-party
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE=RELEASE
    -DJAS_ENABLE_DOC=FALSE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/jasper
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    )
endif()


if(BUILD_ESMF)
  if(${CMAKE_C_COMPILER_ID} STREQUAL "Intel")
    set(comp "intel")
  elseif(${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
    set(comp "gfortran")
  endif()

  ExternalProject_Add(esmf
    PREFIX ${PROJECT_BINARY_DIR}/esmf
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/esmf
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -E env ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf ESMF_COMM=${MPITYPE} ESMF_COMPILER=${comp} ESMF_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} make
    INSTALL_COMMAND ${CMAKE_COMMAND} -E env ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf ESMF_COMM=${MPITYPE} ESMF_COMPILER=${comp} ESMF_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ESMF_INSTALL_HEADERDIR=${CMAKE_INSTALL_PREFIX}/include ESMF_INSTALL_MODDIR=${CMAKE_INSTALL_PREFIX}/include ESMF_INSTALL_LIBDIR=${CMAKE_INSTALL_PREFIX}/lib ESMF_INSTALL_BINDIR=${CMAKE_INSTALL_PREFIX}/bin make install
    )
endif()

