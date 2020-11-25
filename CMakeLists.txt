cmake_minimum_required(VERSION 3.12)
enable_language(Fortran)

project(NCEPLIBS-external)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "default install path" FORCE )
endif()

# CMP0074: find_package uses PackageName_ROOT variables
if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif(POLICY CMP0074)

# Tell cmake what to build
option(BUILD_MPI     "Build MPI"               ON )
option(BUILD_ESMF    "Build ESMF"              ON )
option(BUILD_NETCDF  "Build NetCDF"            ON )
option(BUILD_JASPER  "Build Jasper"            ON )
option(BUILD_PNG     "Build libpng"            ON )
option(DEPLOY        "Deploy modulefiles"      OFF)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# Consistency check. To avoid linking errors with different versions of libz,
# either both NetCDF and PNG must be built or none of them.
if((BUILD_NETCDF OR BUILD_PNG) AND NOT (BUILD_NETCDF AND BUILD_PNG))
  message(FATAL_ERROR "NetCDF and PNG must both be built or both supplied externally")
endif()

set(libs "MPI" "NETCDF" "ESMF" "JASPER" "PNG")
set(libs_to_build)
foreach(lib ${libs})
  if(BUILD_${lib})
    list(APPEND libs_to_build "${lib} ")
  endif()
endforeach()

message(STATUS "Building libraries: " ${libs_to_build})

set(install_path ${CMAKE_INSTALL_PREFIX})

include(ExternalProject)
include(GNUInstallDirs)

if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR})
  file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR})
endif()
set(CMAKE_CONFIG_FILE "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/nceplibs-external.cmake.config")
file(WRITE ${CMAKE_CONFIG_FILE} "# CMake configuration file for NCEPLIBS-external\n")

if(BUILD_MPI)
  if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "GNU" AND ${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 9.9)
    set(MPICH_FORTRAN_FLAGS "-w -fallow-argument-mismatch")
    message(STATUS "Set Fortran flags for compiling MPICH with gfortran-10+: '${MPICH_FORTRAN_FLAGS}'")
  else()
    set(MPICH_FORTRAN_FLAGS "")
  endif()
  set (MPICH_VERSION "3.3.2")
  ExternalProject_Add(mpi
    PREFIX ${PROJECT_BINARY_DIR}/mpich
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/mpich
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    DOWNLOAD_COMMAND cd ${PROJECT_BINARY_DIR}/mpich && tar -xzf ${PROJECT_SOURCE_DIR}/mpich/mpich-${MPICH_VERSION}.tar.gz
    CONFIGURE_COMMAND cd ${PROJECT_BINARY_DIR}/mpich/mpich-${MPICH_VERSION} && ./configure --prefix=${CMAKE_INSTALL_PREFIX} "FFLAGS=${MPICH_FORTRAN_FLAGS}"
    BUILD_COMMAND cd ${PROJECT_BINARY_DIR}/mpich/mpich-${MPICH_VERSION} && $(MAKE) && $(MAKE) check
    INSTALL_COMMAND cd ${PROJECT_BINARY_DIR}/mpich/mpich-${MPICH_VERSION} && $(MAKE) install
    )
  set(MPI_ROOT ${CMAKE_INSTALL_PREFIX})
  set(MPI_C_LIBRARY_VERSION_STRING "MPICH")
  set(MPI_C_VERSION_MAJOR "3")
  file(APPEND ${CMAKE_CONFIG_FILE} "set(MPI_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
else()
  set(MPI_DETERMINE_LIBRARY_VERSION true)
  find_package(MPI REQUIRED)
endif()

if(NOT DEFINED MPITYPE AND BUILD_ESMF)
  if(MPI_C_LIBRARY_VERSION_STRING MATCHES ".*CRAY MPICH.*" AND MPI_C_VERSION_MAJOR MATCHES "3")
    set(MPITYPE "mpi")
  elseif(MPI_C_LIBRARY_VERSION_STRING MATCHES ".*MPICH.*" AND MPI_C_VERSION_MAJOR MATCHES "3")
    set(MPITYPE "mpich3")
  elseif(MPI_C_LIBRARY_VERSION_STRING MATCHES ".*Open MPI.*" AND MPI_C_VERSION_MAJOR MATCHES "3")
    set(MPITYPE "openmpi")
  elseif(MPI_C_LIBRARY_VERSION_STRING MATCHES ".*HPE MPT.*" AND MPI_C_VERSION_MAJOR MATCHES "3")
    set(MPITYPE "mpt")
  elseif(MPI_C_LIBRARY_VERSION_STRING MATCHES ".*Intel.*" AND MPI_C_VERSION_MAJOR MATCHES "3")
    set(MPITYPE "intelmpi")
  else()
    message(FATAL_ERROR "Cannot detect MPI type for ESMF, check that it is supported and set it via -DMPITYPE=... ; calid options are: intelmpi, openmpi, mpich3, mpt, openmpi")
  endif()
  message(STATUS "Set ESMF MPITYPE to ${MPITYPE}")
endif()

if(BUILD_NETCDF OR BUILD_PNG)
  ExternalProject_Add(zlib
    PREFIX ${PROJECT_BINARY_DIR}/zlib
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/zlib
    BINARY_DIR ${PROJECT_BINARY_DIR}/zlib/build
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CONFIGURE_COMMAND ${PROJECT_SOURCE_DIR}/zlib/configure --static --prefix=${CMAKE_INSTALL_PREFIX} --libdir=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    BUILD_COMMAND make
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_BINARY_DIR}/zlib/build && make test
    INSTALL_COMMAND $(MAKE) install
    )

  file(APPEND ${CMAKE_CONFIG_FILE} "set(ZLIB_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
endif()

if(BUILD_NETCDF)
  # This is where the libraries will be
  set(NETCDF_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include)
  set(HDF5_C_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}hdf5${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(HDF5_HL_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}hdf5_hl${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(ZLIB_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}z${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(SZIP_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}sz${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(NETCDF_C_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}netcdf${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(NETCDF_Fortran_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}netcdff${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(NETCDF_LIBRARIES "${NETCDF_Fortran_LIBRARY} ${NETCDF_C_LIBRARY} ${HDF5_HL_LIBRARY} ${HDF5_C_LIBRARY} ${SZIP_LIBRARY} ${ZLIB_LIBRARY}")

  ExternalProject_Add(szip
    PREFIX ${PROJECT_BINARY_DIR}/szip
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/szip
    BINARY_DIR ${PROJECT_BINARY_DIR}/szip/build
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CONFIGURE_COMMAND ${PROJECT_SOURCE_DIR}/szip/configure --enable-static --disable-shared --prefix=${CMAKE_INSTALL_PREFIX} --libdir=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    BUILD_COMMAND make
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_BINARY_DIR}/szip/build && make test
    INSTALL_COMMAND $(MAKE) install
    )

  file(APPEND ${CMAKE_CONFIG_FILE} "set(SZIP_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")

  ExternalProject_Add(hdf5
    PREFIX ${PROJECT_BINARY_DIR}/hdf5
    BINARY_DIR ${PROJECT_BINARY_DIR}/hdf5/build
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_C_COMPILER=${MPI_C_COMPILER}
    -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DHDF5_BUILD_FORTRAN:BOOL=ON
    -DHDF5_ENABLE_PARALLEL=ON
    -DHDF5_BUILD_CPP_LIB=OFF
    -DHDF5_BUILD_HL_LIB:BOOL=ON
    -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
    -DZLIB_ROOT=${CMAKE_INSTALL_PREFIX}
    -DHDF5_ENABLE_SZIP_SUPPORT:BOOL=ON
    -DSZIP_ROOT=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=RELEASE
    -DHDF5_INSTALL_LIB_DIR=${CMAKE_INSTALL_LIBDIR}
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/hdf5
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    #TEST_BEFORE_INSTALL TRUE
    #TEST_COMMAND cd ${PROJECT_BINARY_DIR}/hdf5/build && make test
    DEPENDS zlib
    DEPENDS szip
    )

  # configure NetCDF configure script with installation locations of HDF, install location, etc
  configure_file(${PROJECT_SOURCE_DIR}/config_netcdfc.sh.tmpl ${PROJECT_BINARY_DIR}/config_netcdfc.sh)

  ExternalProject_Add(netcdf
    PREFIX ${PROJECT_BINARY_DIR}/netcdf-c
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/netcdf-c
    BINARY_DIR ${PROJECT_BINARY_DIR}/netcdf-c
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${PROJECT_BINARY_DIR}/config_netcdfc.sh
    BUILD_COMMAND cd ${PROJECT_BINARY_DIR}/netcdf-c && $(MAKE) 
    INSTALL_COMMAND cd ${PROJECT_BINARY_DIR}/netcdf-c && $(MAKE) install
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_BINARY_DIR}/netcdf-c && $(MAKE) check
    DEPENDS hdf5
    DEPENDS zlib
    )

  # configure NetCDF configure script with installation locations of NetCDF, HDF, install location, etc
  if(${CMAKE_Fortran_COMPILER_ID} STREQUAL "GNU" AND ${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 9.9)
    set(NETCDF_FORTRAN_FLAGS "-w -fallow-argument-mismatch")
    message(STATUS "Set netCDF_Fortran_FLAGS for gfortran-10+: '${NETCDF_FORTRAN_FLAGS}'")
  else()
    set(NETCDF_FORTRAN_FLAGS "")
  endif()
  configure_file(${PROJECT_SOURCE_DIR}/config_netcdff.sh.tmpl ${PROJECT_BINARY_DIR}/config_netcdff.sh)

  ExternalProject_Add(netcdf-fortran
    PREFIX ${PROJECT_BINARY_DIR}/netcdf-fortran
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/netcdf-fortran
    BINARY_DIR ${PROJECT_BINARY_DIR}/netcdf-fortran
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${PROJECT_BINARY_DIR}/config_netcdff.sh
    BUILD_COMMAND cd ${PROJECT_BINARY_DIR}/netcdf-fortran && $(MAKE)
    INSTALL_COMMAND cd ${PROJECT_BINARY_DIR}/netcdf-fortran && $(MAKE) install
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_BINARY_DIR}/netcdf-fortran && $(MAKE) check
    DEPENDS netcdf
    )

  file(APPEND ${CMAKE_CONFIG_FILE} "set(HDF5_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
  file(APPEND ${CMAKE_CONFIG_FILE} "set(NETCDF \"${CMAKE_INSTALL_PREFIX}\")\n")
else()
  # Find NetCDF
  add_custom_target(netcdf-fortran)
  find_package(NetCDF COMPONENTS Fortran REQUIRED)
  # Reverse list and replace semicolons with spaces as required for ESMF below
  list(REVERSE NETCDF_LIBRARIES)
  # A rather complicated way to replace ";" with " "
  set(NETCDF_LIBRARIES_TMP "")
  foreach(itemlib ${NETCDF_LIBRARIES})
      set(NETCDF_LIBRARIES_TMP "${NETCDF_LIBRARIES_TMP} ${itemlib}")
  endforeach()
  string(STRIP "${NETCDF_LIBRARIES_TMP}" NETCDF_LIBRARIES)
endif()

if(BUILD_PNG)
  ExternalProject_Add(libpng
    PREFIX ${PROJECT_BINARY_DIR}/libpng
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DZLIB_ROOT=${CMAKE_INSTALL_PREFIX}
    -DPNG_SHARED=OFF
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libpng
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS zlib
    )
  file(APPEND ${CMAKE_CONFIG_FILE} "set(PNG_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
else()
  # Find PNG
  add_custom_target(libpng)
  find_package(PNG REQUIRED)
endif()

if(BUILD_JASPER)
  # Fix the wrong installation directories in libjpeg's CMakeLists.txt
  execute_process(COMMAND patch -N -p0 INPUT_FILE patches/libjpeg.patch WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
  ExternalProject_Add(libjpeg
    PREFIX ${PROJECT_BINARY_DIR}/libjpeg
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libjpeg
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    )

  configure_file(${PROJECT_SOURCE_DIR}/config_jasper.sh.tmpl ${PROJECT_BINARY_DIR}/config_jasper.sh)

  ExternalProject_Add(jasper
    PREFIX ${PROJECT_BINARY_DIR}/jasper
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/jasper
    BINARY_DIR ${PROJECT_BINARY_DIR}/jasper
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${PROJECT_BINARY_DIR}/config_jasper.sh
    BUILD_COMMAND cd ${PROJECT_BINARY_DIR}/jasper && $(MAKE)
    INSTALL_COMMAND cd ${PROJECT_BINARY_DIR}/jasper && $(MAKE) install
    DEPENDS libjpeg
    )

  file(APPEND ${CMAKE_CONFIG_FILE} "set(JPEG_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
  file(APPEND ${CMAKE_CONFIG_FILE} "set(Jasper_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
else()
  # Find JPEG and Jasper
  add_custom_target(libjpeg)
  find_package(JPEG)
  add_custom_target(jasper)
  find_package(Jasper REQUIRED)
endif()

if(BUILD_ESMF)
  if(${CMAKE_C_COMPILER_ID} STREQUAL "Intel")
    set(comp "intel")
    set(ESMF_BOPT "O")
    set(ESMF_OPTLEVEL "2")
    set(ESMF_F90COMPILEOPTS "-g -traceback -fp-model precise")
    set(ESMF_CXXCOMPILEOPTS "-g -traceback -fp-model precise")
  elseif(${CMAKE_C_COMPILER_ID} MATCHES "^(GNU|Clang|AppleClang)$")
    set(comp "gfortran")
    # Compiling with optimization can lead to crashes on macOS
    if(APPLE)
      set(ESMF_BOPT "O")
      set(ESMF_OPTLEVEL "0")
      if (${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 9.9)
        set(ESMF_F90COMPILEOPTS "-g -fbacktrace -fallow-argument-mismatch")
      else()
        set(ESMF_F90COMPILEOPTS "-g -fbacktrace")
      endif()
      set(ESMF_CXXCOMPILEOPTS "-g -Wno-error=format-security")
    else()
      set(ESMF_BOPT "O")
      set(ESMF_OPTLEVEL "2")
      if (${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER 9.9)
        set(ESMF_F90COMPILEOPTS "-g -fbacktrace -fallow-argument-mismatch")
      else()
        set(ESMF_F90COMPILEOPTS "-g -fbacktrace")
      endif()
      set(ESMF_CXXCOMPILEOPTS "-g")
    endif()
    message(STATUS "Setting ESMF_F90COMPILEOPTS: '${ESMF_F90COMPILEOPTS}'")
  endif()

  if(NOT BUILD_MPI)
    add_custom_target(mpi)
    set(ESMF_PATH $ENV{PATH})
  else()
    set(ESMF_PATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}:$ENV{PATH}")
  endif()

  # When building only the static ESMF library, cannot run tests on macOS and certain Linux machines (e.g. Travis)
  ExternalProject_Add(esmf
    PREFIX ${PROJECT_BINARY_DIR}/esmf
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/esmf
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -E env PATH=${ESMF_PATH} ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf ESMF_COMM=${MPITYPE} ESMF_COMPILER=${comp} ESMF_NETCDF=1 ESMF_NETCDF_INCLUDE=${NETCDF_INCLUDE_DIRS} ESMF_NETCDF_LIBS=${NETCDF_LIBRARIES} ESMF_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ESMF_BOPT=${ESMF_BOPT} ESMF_SHARED_LIB_BUILD=OFF ESMF_OPTLEVEL=${ESMF_OPTLEVEL} ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS} ESMF_CXXCOMPILEOPTS=${ESMF_CXXCOMPILEOPTS} $(MAKE)
    #TEST_COMMAND cd ${PROJECT_SOURCE_DIR}/esmf && make check ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf
    #TEST_BEFORE_INSTALL TRUE
    INSTALL_COMMAND ${CMAKE_COMMAND} -E env PATH=${ESMF_PATH} ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf ESMF_COMM=${MPITYPE} ESMF_COMPILER=${comp} ESMF_NETCDF=1 ESMF_NETCDF_INCLUDE=${NETCDF_INCLUDE_DIRS} ESMF_NETCDF_LIBS=${NETCDF_LIBRARIES} ESMF_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ESMF_INSTALL_HEADERDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR} ESMF_INSTALL_MODDIR=${CMAKE_INSTALL_PREFIX}/mod ESMF_INSTALL_LIBDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR} ESMF_INSTALL_BINDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR} ESMF_BOPT=${ESMF_BOPT} ESMF_OPTLEVEL=${ESMF_OPTLEVEL} ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS} ESMF_CXXCOMPILEOPTS=${ESMF_CXXCOMPILEOPTS} $(MAKE) install
    DEPENDS mpi netcdf-fortran)

  file(APPEND ${CMAKE_CONFIG_FILE} "set(ESMFMKFILE \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/esmf.mk\")\n")
endif()

# Option to overwrite modulefile (if DEPLOY = ON)
if(DEPLOY)
  message(STATUS "Installing modulefiles at ${CMAKE_INSTALL_PREFIX}/modules")
  if(BUILD_PNG)
    set(PNG_VERSION "1.6.35")
    configure_file(${PROJECT_SOURCE_DIR}/tmplModulefiles/libpng ${CMAKE_INSTALL_PREFIX}/modules/libpng/${PNG_VERSION})
  endif()
  if(BUILD_NETCDF)
    set(NETCDF_VERSION "4.7.4")
    configure_file(${PROJECT_SOURCE_DIR}/tmplModulefiles/netcdf ${CMAKE_INSTALL_PREFIX}/modules/netcdf/${NETCDF_VERSION})
  endif()
  if(BUILD_ESMF)
    set(ESMF_VERSION "8.1.0bs27")
    configure_file(${PROJECT_SOURCE_DIR}/tmplModulefiles/esmf ${CMAKE_INSTALL_PREFIX}/modules/esmf/${ESMF_VERSION})
  endif()
endif()
