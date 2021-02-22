# A helper script to check for a sufficiently modern compiler.  Some
# DSL libraries require the use of C++11 features that are not
# supported under the version of gcc shipped with Ubuntu 12.04.
# Those libraries should include this cmake helper script.

# SS - Try to determine whether the user has installed GCC 4.8.  If
#      not, notify the user to install it.
if (CMAKE_COMPILER_IS_GNUCXX)
  execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                  OUTPUT_VARIABLE GCC_VERSION)
  string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
  list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
  #list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)

  message(STATUS "Found gcc ${GCC_VERSION}")

endif()
if (GCC_VERSION VERSION_GREATER 4.8 OR GCC_VERSION VERSION_EQUAL 4.8)
  message(STATUS "Detected G++ >= 4.8")
  add_definitions("-std=gnu++11")
else()
  message(FATAL_ERROR "This library requires C++11 features supported only by GCC versions >= 4.8.  dslmeta/scripts/gcc-4.8.1/ contains scripts to compile and install gcc-4.8.1 from source.")
endif()

