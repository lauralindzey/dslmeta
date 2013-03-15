# Set install path for all DSL software.
SET( DSL_INSTALL_PREFIX /opt/dsl )

# The following breaks with cmake convention.  We force a Debug build
# and force an installation prefix.  These values cannot be overridden
# by the user.

# Set default build options to Debug and add some compiler flags.  Users
# can overwrite the compile flags by setting CMAKE_CXX_FLAGS in their
# project CMakeLists.txt files. Also increase make's verbosity by default.
# The build process will be much more verbose but the actual calls to gcc 
# will be printed.  Note: the FORCE option is needed to make these values 
# show up in the cmake GUI (ccmake) but also disallows changes by the user.
SET( CMAKE_BUILD_TYPE 
  Debug CACHE STRING "Build type (Forced)" FORCE
  )
set(CMAKE_CXX_FLAGS_DEBUG 
  "-Wall -Wwrite-strings -ggdb" CACHE STRING "Debug compiler flags (Forced)." FORCE)
set(CMAKE_VERBOSE_MAKEFILE ON)

# Set installation location prefix, used on 'make install'.
SET(CMAKE_INSTALL_PREFIX
  ${DSL_INSTALL_PREFIX} CACHE PATH "Install prefix for binaries, headers, etc. (Forced)" FORCE
  )

# Enforce building from the build subdirectory only.  Annoyingly, cmake cache files will still be created.
STRING(COMPARE EQUAL "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/build" INBUILD)
IF(NOT INBUILD)
  MESSAGE(FATAL_ERROR "This project enforces and out-of-source build.  Please cd to the 'build' directory to run cmake: 'cmake ../'.")
ENDIF(NOT INBUILD)
