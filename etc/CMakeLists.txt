

# Try to determine whether the user has configured their environment
# for DSL software and prompt them to source ./environment if not.
# This is a fatal error because downstream errors in other
# repositories will appear cryptic if the environment is not properly
# configured.
# IF(NOT DEFINED ENV{DSL_INSTALL_PREFIX})
#   MESSAGE(FATAL_ERROR "Your environment does not appear to be set up for DSL software development.  Please source ${CMAKE_CURRENT_LIST_DIR}/environment from your shell and add the line 'source ${CMAKE_CURRENT_LIST_DIR}/environment' to your .bashrc file.")
# ENDIF()
