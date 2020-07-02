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
option(BUILD_MPI "Build MPI?" ON)
option(BUILD_ESMF "Build ESMF?" ON)
option(BUILD_NETCDF "Build NetCDF?" ON)
option(BUILD_JASPER "Build Jasper?" ON)
option(BUILD_PNG "Build libpng?" ON)
option(BUILD_WGRIB2 "Build wgrib2?" ON)

# Indicate to cmake what the default link type is
option(STATIC_IS_DEFAULT "turn on for systems that use static linking by default" OFF)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# Consistency check. To avoid linking errors with different versions of libz,
# either both NetCDF and PNG must be built or none of them.
if((BUILD_NETCDF OR BUILD_PNG) AND NOT (BUILD_NETCDF AND BUILD_PNG))
  message(FATAL_ERROR "NetCDF and PNG must both be built or both supplied externally")
endif()

set(libs "MPI" "NETCDF" "ESMF" "JASPER" "PNG" "WGRIB2")
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
  set (MPICH_VERSION "3.3.2")
  ExternalProject_Add(mpi
    PREFIX ${PROJECT_BINARY_DIR}/mpich
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/mpich
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    DOWNLOAD_COMMAND cd ${PROJECT_BINARY_DIR}/mpich && tar -xzf ${PROJECT_SOURCE_DIR}/mpich/mpich-${MPICH_VERSION}.tar.gz
    CONFIGURE_COMMAND cd ${PROJECT_BINARY_DIR}/mpich/mpich-${MPICH_VERSION} && ./configure --prefix=${CMAKE_INSTALL_PREFIX}
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
  # Fix the wrong installation directories in zlib's CMakeLists.txt
  execute_process(COMMAND patch -N -p0 INPUT_FILE patches/zlib.patch WORKING_DIRECTORY ${PROJECT_SOURCE_DIR})
  ExternalProject_Add(zlib
    PREFIX ${PROJECT_BINARY_DIR}/zlib
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/zlib
    BINARY_DIR ${PROJECT_BINARY_DIR}/zlib/build
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    CONFIGURE_COMMAND ${PROJECT_SOURCE_DIR}/zlib/configure --static --prefix=${CMAKE_INSTALL_PREFIX}
    BUILD_COMMAND make
    INSTALL_COMMAND $(MAKE) install
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_BINARY_DIR}/zlib/build && make test
    )
  
  file(APPEND ${CMAKE_CONFIG_FILE} "set(ZLIB_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
endif()

if(BUILD_NETCDF)
  # This is where the libraries will be
  set(NETCDF_INCLUDES ${CMAKE_INSTALL_PREFIX}/include)
  set(NETCDF_LIBRARIES_C ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}netcdf${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(NETCDF_LIBRARIES_Fortran ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}netcdff${CMAKE_STATIC_LIBRARY_SUFFIX})
    
  set(NETCDF_LIBRARIES "${NETCDF_LIBRARIES_Fortran} ${NETCDF_LIBRARIES_C}")

  ExternalProject_Add(hdf5
    PREFIX ${PROJECT_BINARY_DIR}/hdf5
    BINARY_DIR ${PROJECT_BINARY_DIR}/hdf5/build
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_C_COMPILER=${MPI_C_COMPILER}
    -DCMAKE_Fortran_COMPILER=${MPI_Fortran_COMPILER}
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DHDF5_BUILD_FORTRAN:BOOL=ON
    -DHDF5_ENABLE_PARALLEL=OFF
    -DHDF5_BUILD_CPP_LIB=OFF
    -DHDF5_BUILD_HL_LIB:BOOL=ON
    -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
    -DZLIB_DIR=${CMAKE_INSTALL_PREFIX}
    -DHDF5_ENABLE_SZIP_SUPPORT:BOOL=OFF
    -DCMAKE_BUILD_TYPE=RELEASE
    -DHDF5_INSTALL_LIB_DIR=${CMAKE_INSTALL_LIBDIR}
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/hdf5
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_BINARY_DIR}/hdf5/build && make test
    DEPENDS zlib
    )

  # Used by configure_file for the configure scripts
  set(NCDIR ${CMAKE_INSTALL_PREFIX})
  set(H5DIR ${CMAKE_INSTALL_PREFIX})
  set(ZDIR ${CMAKE_INSTALL_PREFIX})

  set(HDF5_C_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}hdf5${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(HDF5_HL_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}hdf5_hl${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(ZLIB_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}z${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(NETCDF_C_LIBRARY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}netcdf${CMAKE_STATIC_LIBRARY_SUFFIX})

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
endif()

if(BUILD_PNG)
  ExternalProject_Add(libpng
    PREFIX ${PROJECT_BINARY_DIR}/libpng
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DZLIB_ROOT=${CMAKE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=RELEASE
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libpng
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    DEPENDS zlib
    )
  file(APPEND ${CMAKE_CONFIG_FILE} "set(PNG_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
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

  # Fix RPATH issue on systems that link statically by default
  if(STATIC_IS_DEFAULT)
    ExternalProject_Add(jasper
      PREFIX ${PROJECT_BINARY_DIR}/jasper
      CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DJAS_ENABLE_DOC=FALSE
      -DCMAKE_SKIP_RPATH=TRUE
      SOURCE_DIR ${PROJECT_SOURCE_DIR}/jasper
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
      DEPENDS libjpeg
      )
  else()
    ExternalProject_Add(jasper
      PREFIX ${PROJECT_BINARY_DIR}/jasper
      CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DJAS_ENABLE_DOC=FALSE
      SOURCE_DIR ${PROJECT_SOURCE_DIR}/jasper
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
      DEPENDS libjpeg
      )
  endif()

  file(APPEND ${CMAKE_CONFIG_FILE} "set(JPEG_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
  file(APPEND ${CMAKE_CONFIG_FILE} "set(Jasper_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
endif()

if(BUILD_WGRIB2)
  if(${CMAKE_C_COMPILER_ID} STREQUAL "Intel")
    set(COMP_SYS intel_linux)
  elseif(${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
    set(COMP_SYS gnu_linux)
  elseif(${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
    set(COMP_SYS clang_linux)
  else()
    message(FATAL_ERROR "Unknown compiler, cannot configure wgrib2")
  endif()

  # Don't build the wgrib2 executable on systems that link statically by default, this causes all sorts of problems; just build the library
  if(STATIC_IS_DEFAULT)
    ExternalProject_Add(wgrib2
      PREFIX ${PROJECT_BINARY_DIR}/wgrib2
      SOURCE_DIR ${PROJECT_SOURCE_DIR}/wgrib2
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
      BUILD_IN_SOURCE 1
      CONFIGURE_COMMAND cd ${PROJECT_BINARY_DIR}/wgrib2 && tar -xvf ${PROJECT_SOURCE_DIR}/wgrib2/wgrib2-2.0.8.tar.gz  && patch -N -p0 < ${PROJECT_SOURCE_DIR}/patches/wgrib2.patch
      # Do not use $(MAKE), because it seems wgrib2 sometimes fails to build when multiple threads are used (to be tested further)
      BUILD_COMMAND cd ${PROJECT_BINARY_DIR}/wgrib2/grib2 && CC=${CMAKE_C_COMPILER} FC=${CMAKE_Fortran_COMPILER} COMP_SYS=${COMP_SYS} make lib
      INSTALL_COMMAND cd ${PROJECT_BINARY_DIR}/wgrib2/grib2 && ${PROJECT_SOURCE_DIR}/wgrib2/install.sh ${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_LIBDIR}
      )
  else()
    ExternalProject_Add(wgrib2
      PREFIX ${PROJECT_BINARY_DIR}/wgrib2
      SOURCE_DIR ${PROJECT_SOURCE_DIR}/wgrib2
      INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
      BUILD_IN_SOURCE 1
      CONFIGURE_COMMAND cd ${PROJECT_BINARY_DIR}/wgrib2 && tar -xvf ${PROJECT_SOURCE_DIR}/wgrib2/wgrib2-2.0.8.tar.gz  && patch -N -p0 < ${PROJECT_SOURCE_DIR}/patches/wgrib2.patch
      BUILD_COMMAND cd ${PROJECT_BINARY_DIR}/wgrib2/grib2 && CC=${CMAKE_C_COMPILER} FC=${CMAKE_Fortran_COMPILER} COMP_SYS=${COMP_SYS} make && CC=${CMAKE_C_COMPILER} FC=${CMAKE_Fortran_COMPILER} COMP_SYS=${COMP_SYS} make lib
      INSTALL_COMMAND cd ${PROJECT_BINARY_DIR}/wgrib2/grib2 && ${PROJECT_SOURCE_DIR}/wgrib2/install.sh ${CMAKE_INSTALL_PREFIX} ${CMAKE_INSTALL_LIBDIR}
      )
  endif()
  file(APPEND ${CMAKE_CONFIG_FILE} "set(WGRIB2_ROOT \"${CMAKE_INSTALL_PREFIX}\")\n")
endif()

if(BUILD_ESMF)
  
  if(${CMAKE_C_COMPILER_ID} STREQUAL "Intel")
    set(comp "intel")
    set(ESMF_BOPT "O")
    set(ESMF_OPTLEVEL "2")
    set(ESMF_F90COMPILEOPTS "-g -traceback -fp-model precise")
    set(ESMF_CXXCOMPILEOPTS "-g -traceback -fp-model precise")
  elseif(${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
    set(comp "gfortran")
    # Compiling with optimization can lead to crashes on macOS
    if(APPLE)
      set(ESMF_BOPT "O")
      set(ESMF_OPTLEVEL "0")
      set(ESMF_F90COMPILEOPTS "-g -fbacktrace")
      set(ESMF_CXXCOMPILEOPTS "-g -Wno-error=format-security")
    else()
      set(ESMF_BOPT "O")
      set(ESMF_OPTLEVEL "2")
      set(ESMF_F90COMPILEOPTS "-g -fbacktrace")
      set(ESMF_CXXCOMPILEOPTS "-g")
    endif()
  endif()

  if(NOT BUILD_NETCDF)
    # Find NetCDF and convert output to what ESMF expects
    add_custom_target(netcdf-fortran)
    set(NETCDF_USE_STATIC_LIBRARIES TRUE)

    if(NOT DEFINED ENV{NETCDF})
      message(FATAL_ERROR "Environment variable NETCDF not set")
    else()
      list(APPEND CMAKE_PREFIX_PATH $ENV{NETCDF})
    endif()
    if(DEFINED ENV{NETCDF_FORTRAN})
      list(APPEND CMAKE_PREFIX_PATH $ENV{NETCDF_FORTRAN})
    endif()
    find_package(NetCDF MODULE REQUIRED)
    # Process NETCDF_INCLUDES string to what ESMF expects
    separate_arguments(NETCDF_INCLUDES)
    list(REMOVE_DUPLICATES NETCDF_INCLUDES)
    set(NETCDF_INCLUDES_TMP "")
    foreach(item ${NETCDF_INCLUDES})
        set(NETCDF_INCLUDES_TMP "${NETCDF_INCLUDES_TMP} ${item}")
    endforeach()
    string(STRIP "${NETCDF_INCLUDES_TMP}" NETCDF_INCLUDES)
    # Convert NETCDF_LIBRARIES string to what ESMF expects
    string(REPLACE " -L" ";-L" NETCDF_LIBRARIES ${NETCDF_LIBRARIES})
    set(NETCDF_LIBRARIES_WITH_DEPS "")
    foreach(item ${NETCDF_LIBRARIES})
        string(REGEX MATCHALL "-L[^ ]*" itempath "${item}")
        string(REGEX REPLACE "^-L" "" itempath ${itempath})
        string(REGEX MATCHALL "-l[^ ]*" itemlibs "${item}")
        foreach(itemlib ${itemlibs})
          string(REGEX REPLACE "^-l" "" itemlib ${itemlib})
          set(sharedlib ${itempath}/${CMAKE_SHARED_LIBRARY_PREFIX}${itemlib}${CMAKE_SHARED_LIBRARY_SUFFIX})
          set(staticlib ${itempath}/${CMAKE_STATIC_LIBRARY_PREFIX}${itemlib}${CMAKE_STATIC_LIBRARY_SUFFIX})
          if(EXISTS ${sharedlib})
            set(NETCDF_LIBRARIES_WITH_DEPS "${NETCDF_LIBRARIES_WITH_DEPS} ${sharedlib}")
          else()
            set(NETCDF_LIBRARIES_WITH_DEPS "${NETCDF_LIBRARIES_WITH_DEPS} ${staticlib}")
          endif()
        endforeach()
    endforeach()
    string(STRIP "${NETCDF_LIBRARIES_WITH_DEPS}" NETCDF_LIBRARIES_WITH_DEPS)
  else()
    set(NETCDF_LIBRARIES_WITH_DEPS "${NETCDF_LIBRARIES} ${HDF5_HL_LIBRARY} ${HDF5_C_LIBRARY} ${ZLIB_LIBRARY}")
  endif()

  if(NOT BUILD_MPI)
    add_custom_target(mpi)
    set(ESMF_PATH $ENV{PATH})
  else()
    set(ESMF_PATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}:$ENV{PATH}")
  endif()

  ExternalProject_Add(esmf
    PREFIX ${PROJECT_BINARY_DIR}/esmf
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/esmf
    INSTALL_DIR ${CMAKE_INSTALL_PREFIX}
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_COMMAND} -E env PATH=${ESMF_PATH} ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf ESMF_COMM=${MPITYPE} ESMF_COMPILER=${comp} ESMF_NETCDF=1 ESMF_NETCDF_INCLUDE=${NETCDF_INCLUDES} ESMF_NETCDF_LIBS=${NETCDF_LIBRARIES_WITH_DEPS} ESMF_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ESMF_BOPT=${ESMF_BOPT} ESMF_OPTLEVEL=${ESMF_OPTLEVEL} ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS} ESMF_CXXCOMPILEOPTS=${ESMF_CXXCOMPILEOPTS} $(MAKE)
    INSTALL_COMMAND ${CMAKE_COMMAND} -E env PATH=${ESMF_PATH} ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf ESMF_COMM=${MPITYPE} ESMF_COMPILER=${comp} ESMF_NETCDF=1 ESMF_NETCDF_INCLUDE=${NETCDF_INCLUDES} ESMF_NETCDF_LIBS=${NETCDF_LIBRARIES_WITH_DEPS} ESMF_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ESMF_INSTALL_HEADERDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR} ESMF_INSTALL_MODDIR=${CMAKE_INSTALL_PREFIX}/mod ESMF_INSTALL_LIBDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR} ESMF_INSTALL_BINDIR=${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR} ESMF_BOPT=${ESMF_BOPT} ESMF_OPTLEVEL=${ESMF_OPTLEVEL} ESMF_F90COMPILEOPTS=${ESMF_F90COMPILEOPTS} ESMF_CXXCOMPILEOPTS=${ESMF_CXXCOMPILEOPTS} $(MAKE) install
    TEST_BEFORE_INSTALL TRUE
    TEST_COMMAND cd ${PROJECT_SOURCE_DIR}/esmf && make check ESMF_DIR=${PROJECT_SOURCE_DIR}/esmf
    DEPENDS mpi netcdf-fortran)

  if(APPLE)
    ExternalProject_Add_Step(esmf POST_INSTALL
    COMMAND ${PROJECT_SOURCE_DIR}/patches/esmf_macos_install_name_tool_fix.sh ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR} ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    DEPENDEES install)
  endif()

  file(APPEND ${CMAKE_CONFIG_FILE} "set(ESMFMKFILE \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/esmf.mk\")\n")
endif()
