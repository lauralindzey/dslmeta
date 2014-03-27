

# Try to determine whether the user has configured their environment
# for DSL software and prompt them to source ./environment if not.
# This is a fatal error because downstream errors in other
# repositories will appear cryptic if the environment is not properly
# configured.
IF(NOT DEFINED ENV{DSL_INSTALL_PREFIX})
  MESSAGE(FATAL_ERROR "Your environment does not appear to be set up for DSL software development.  Please source ${CMAKE_CURRENT_LIST_DIR}/environment from your shell and add the line 'source ${CMAKE_CURRENT_LIST_DIR}/environment' to your .bashrc file.")
ENDIF()

# SS - Try to determine whether the user has installed GCC 4.8.  If not, notify the user to install it.
if (CMAKE_COMPILER_IS_GNUCXX)
  execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                  OUTPUT_VARIABLE GCC_VERSION)
  string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
  list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
  list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)

  message(STATUS ${GCC_MAJOR})
  message(STATUS ${GCC_MINOR})
endif()
if (GCC_VERSION VERSION_GREATER 4.8 OR GCC_VERSION VERSION_EQUAL 4.8)
  message(STATUS "Detected G++ >= 4.8")
else()
  message(FATAL_ERROR "Error: please install GCC >= 4.8")
endif()

FIND_PACKAGE(Boost 1.55.0 REQUIRED)
