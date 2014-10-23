# Set install path for all DSL software.
SET( DSL_INSTALL_PREFIX /opt/dsl )

# Set the vehicle to build for.  

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
set(CMAKE_CXX_FLAGS_DEBUG 
  "-Wall -Wwrite-strings -ggdb -Og" CACHE STRING "Debug compiler flags." FORCE)

set(CMAKE_VERBOSE_MAKEFILE ON)

# Set installation location prefix, used on 'make install'.  Generally
# should not be changed because only the default is placed on the
# users path.  In this case cmake initializes this variable by default
# (/usr/local), so the solution is different from CMAKE_BUILD_TYPE:
# http://stackoverflow.com/questions/16074598/set-installation-prefix-automatically-to-custom-path-if-not-explicitly-specified
IF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  SET(CMAKE_INSTALL_PREFIX
    ${DSL_INSTALL_PREFIX} CACHE PATH 
    "Install prefix for binaries, headers, etc." FORCE
    )
ENDIF(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

# Enforce building from the build subdirectory only.  Annoyingly,
# cmake cache files will still be created.  It is not possible to
# e.g. EXECUTE_PROCESS to remove these files:
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
