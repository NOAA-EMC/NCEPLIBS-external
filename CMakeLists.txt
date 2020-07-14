cmake_minimum_required(VERSION 3.15)

project(
  NCEPLIBS-external
  VERSION 1.0.0
  LANGUAGES C CXX Fortran)

include(ExternalProject)
include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE MATCHES "^(Debug|Release|RelWithDebInfo|MinSizeRel)$")
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE
    "Release"
    CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
    "MinSizeRel" "RelWithDebInfo")
endif()

if(NOT CMAKE_C_COMPILER_ID MATCHES "^(Intel|GNU|Clang|AppleClang)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_C_COMPILER_ID}")
endif()

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "^(Intel|GNU|Clang|AppleClang)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_CXX_COMPILER_ID}")
endif()

if(NOT CMAKE_Fortran_COMPILER_ID MATCHES "^(Intel|GNU)$")
  message(WARNING "Compiler not officially supported: ${CMAKE_Fortran_COMPILER_ID}")
endif()

find_package(MPI REQUIRED)

# zlib
set(zlibVer "v1.2.11")
ExternalProject_Add(zlib
  GIT_REPOSITORY "https://github.com/madler/zlib"
  GIT_TAG        "${zlibVer}"
  PREFIX         "${CMAKE_BINARY_DIR}/zlib"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/zlib-${zlibVer}"
                 "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
  )

# libpng
set(libpngVer "v1.6.35")
ExternalProject_Add(libpng
  GIT_REPOSITORY "https://github.com/glennrp/libpng"
  GIT_TAG        "${libpngVer}"
  PREFIX         "${CMAKE_BINARY_DIR}/libpng"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/libpng-${libpngVer}"
                 "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
                 "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
  DEPENDS        zlib
  )

# libjpeg
set(libjpegVer "8.4.0")
ExternalProject_Add(libjpeg
  GIT_REPOSITORY "https://github.com/LuaDist/libjpeg"
  GIT_TAG        "${libjpegVer}"
  PREFIX         "${CMAKE_BINARY_DIR}/libjpeg"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/libjpeg-v${libjpegVer}"
                 "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
                 "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
                 "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
  )

# jasper
set(jasperVer "2.0.16")
ExternalProject_Add(jasper
  GIT_REPOSITORY "https://github.com/mdadams/jasper"
  GIT_TAG        "version-${jasperVer}"
  PREFIX         "${CMAKE_BINARY_DIR}/jasper"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/jasper-v${jasperVer}"
                 "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
                 "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
                 "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
                 "-DJAS_ENABLE_DOC=FALSE"
  DEPENDS        libjpeg
  )

# udunits
set(udunitsVer "v2.2.27")
ExternalProject_Add(udunits
  GIT_REPOSITORY "https://github.com/Unidata/UDUNITS-2"
  GIT_TAG        "${udunitsVer}"
  PREFIX         "${CMAKE_BINARY_DIR}/udunits"
  CMAKE_ARGS     "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/udunits-${udunitsVer}"
                 "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
                 "-DCMAKE_PREFIX_PATH=${CMAKE_INSTALL_PREFIX}"
  )
