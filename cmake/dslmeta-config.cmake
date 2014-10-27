# Set install path for all DSL software.
SET( DSL_INSTALL_PREFIX /opt/dsl )

# Set default build options to Debug and add some compiler flags.
# Users can overwrite the compile flags by setting CMAKE_CXX_FLAGS in
# their project CMakeLists.txt files. Also increase make's verbosity
# by default.  The build process will be much more verbose but the
# actual calls to gcc will be printed.  By placing these SET() calls
# within an IF block, the default is set but users may override it.  A
# pure SET call with the FORCE option disallows user modification
# entirely, whereas without the FORCE option no default is set because
# ccmake initializes CMAKE_BUILD_TYPE to an empty string upon the call 
# to PROJECT():
# http://www.cmake.org/pipermail/cmake/2008-September/023808.html
# Most variables do not require this wrapper.
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Debug CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

# Calling PROJECT sets this to compiler-specific defaults and there is
# no clean work-around.  For now leaving this as not alterable by the
# user (FORCE).  
# Work-around for advanced users is to use a different build type and 
# specify custom flags there.
set(CMAKE_CXX_FLAGS_DEBUG 
  "-Wall -Wwrite-strings -ggdb -Og" CACHE STRING "Debug compiler flags." FORCE)

set(CMAKE_VERBOSE_MAKEFILE ON)

# Force installation location prefix, used on 'make install'.  
# Forcing is deliberate to prevent multiple vehicle installations on the
# same machine.  This does not prevent repository-local development and
# compilation for a different vehicle.
#
# If a need arises to change this in the future, check the predefined
# CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT variable to set a default
# that can be overridden by users.
#
# A work-around is to soft-link /opt/dsl to some other location and change
# that link as needed if developing for multiple vehicles simultaneously.
SET(CMAKE_INSTALL_PREFIX
  ${DSL_INSTALL_PREFIX} CACHE PATH 
  "Install prefix for binaries, headers, etc. (Forced.)" FORCE
  )

# Enforce building from the build subdirectory only.  Annoyingly,
# cmake cache files will still be created.  It is not possible to
# use e.g. EXECUTE_PROCESS to remove these files:
# http://public.kitware.com/Bug/view.php?id=6672
# so just tell the user to.
STRING(COMPARE EQUAL "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/build" INBUILD)
IF(NOT INBUILD)
  MESSAGE(FATAL_ERROR "This project enforces and out-of-source build.  Please remove CmakeCache.txt and the CMakeFiles directory just created in the current directory, then cd to the 'build' directory to run cmake: 'cmake ../'.")
ENDIF(NOT INBUILD)

# http://www.cmake.org/Wiki/CMake_RPATH_handling With these settings
# you will be able to execute your programs from the build tree and
# they will find the shared libraries in the build tree and also the
# shared libraries outside your project, when installing all
# executables and shared libraries will be relinked, so they will find
# all libraries they need.  
#
# Use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# When building, don't use the install RPATH already
# (but do use it later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/${PROJECT_NAME}")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Macro for inclusion of libraries etc. from *-config.cmake scripts in
# this directory.  FIND_PACKAGE called with the REQUIRED option produces
# a fatal error that is unhelpful if the problem is actually with the .cmake 
# helper script in dslmeta.  Call FIND_PACKAGE without the REQUIRED option
# and generate a custom (but still fatal) message.  
MACRO(DSLINCLUDE arg1)
  IF (NOT EXISTS ${CMAKE_INSTALL_PREFIX}/cmake/${arg1}-config.cmake)
    MESSAGE(FATAL_ERROR "No cmake config file (${arg1}-config.cmake) for the requested package is defined in dslmeta, or dslmeta needs to be reinstalled.")
  ENDIF(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/cmake/${arg1}-config.cmake)
  MESSAGE("Using ${arg1}-config.cmake from dslmeta to include package ${arg1}")
  FIND_PACKAGE(${arg1})
  IF (${arg1}_FOUND)
    INCLUDE(${${arg1}_CONFIG})
  ELSE(${arg1}_FOUND)
    MESSAGE("Unable to find package ${arg1} using ${CMAKE_INSTALL_PREFIX}/cmake/${arg1}-config.cmake.  dslmeta may need to be rebuilt and installed.")
  ENDIF(${arg1}_FOUND)
  MESSAGE("Successfully included package ${arg1}")
ENDMACRO(DSLINCLUDE arg1)


# Require the user set a specific vehicle to build for.  Do this via
# cmake -DTARGET_VEHICLE:STRING=<vehicle> or ccmake.  This dynamically
# creates target_vehicle.cmake in this directory which is then
# installed upon 'make install'.  Developers can choose to include it
# in (any/all) of their downstream CMakeLists.txt files.
#
# Deliberately do NOT set a list of supported vehicles.  Developers
# should be free to define as many vehicles and vehicle configurations
# as they like.  Defining an supported list here would do nothing
# since there is no way to enforce the same names in downstream
# repositories.

# Force users to specify a target vehicle, but only if building
# dslmeta itself and generate the target_vehicle-config.cmake file for
# inclusion in downstream repositories.
IF(${CMAKE_PROJECT_NAME} STREQUAL "dslmeta")
  SET ( TARGET_VEHICLE "" CACHE STRING
    "Required.  Set to target vehicle's name.")
  IF(NOT TARGET_VEHICLE)
    MESSAGE(FATAL_ERROR "The vehicle to build for must be specified as a string, e.g. 'cmake -DTARGET_VEHICLE:STRING=NUI ../' or use ccmake.")
  ENDIF(NOT TARGET_VEHICLE)

  # Generate target_vehicle.cmake.  On execution will force in the
  # local cache creation or overwriting of a cache variable called
  # INSTALLED_TARGET_VEHICLE.  It also creates a cache variable 
  # called TARGET_VEHICLE if it does not already exist in the cache.
  # If TARGET_VEHICLE already exists in the cache its value will NOT
  # be overwritten.
  SET(TARGET_VEHICLE_CONFIG_FNAME 
    "${CMAKE_CURRENT_LIST_DIR}/target_vehicle-config.cmake")
  FILE(WRITE ${TARGET_VEHICLE_CONFIG_FNAME} 
    "# This file is generated by cmake from dslmeta.\n")
  FILE(APPEND ${TARGET_VEHICLE_CONFIG_FNAME} 
    "# Do not modify by hand.\n")
  FILE(APPEND ${TARGET_VEHICLE_CONFIG_FNAME} 
    "SET(TARGET_VEHICLE \"${TARGET_VEHICLE}\" CACHE STRING \"Target vehicle for conditional builds.\")\n")
  FILE(APPEND ${TARGET_VEHICLE_CONFIG_FNAME} 
    "SET(INSTALLED_TARGET_VEHICLE \"${TARGET_VEHICLE}\" CACHE STRING \"Installed target vehicle.  (Forced.)\" FORCE)\n")

ENDIF(${CMAKE_PROJECT_NAME} STREQUAL "dslmeta")

# Vehicle-specific scripts in dslmeta must be written in cmake and
# executed as in 
# cmake -P <cmake_script> [-C ../build/CMakeCache.txt]
#
# The cmake cache is accessible but unalterable by such scripts.  In
# external repositories, developers can choose to use vehicle-specific
# compilation by using the helper macros included next.
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/target_vehicle_macros.cmake)


# Force default lib and bin directory when using dslmeta
# Set locations for binary outputs.
SET( LIBRARY_OUTPUT_PATH     ${PROJECT_SOURCE_DIR}/lib )
SET( EXECUTABLE_OUTPUT_PATH  ${PROJECT_SOURCE_DIR}/bin )
