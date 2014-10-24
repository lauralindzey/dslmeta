# Helper functions to check which vehicle is being compiled for and
# ensure consistency with the cmake cache.

# Print the name of the vehicle in the cache local to this repository
# as a string.
MACRO(print_target_vehicle_name)
  IF(NOT TARGET_VEHICLE)
    MESSAGE(FATAL_ERROR "Target vehicle is not defined.  Recompile dslmeta.")
  ENDIF(NOT TARGET_VEHICLE)
  MESSAGE("Target vehicle is ${TARGET_VEHICLE}")
ENDMACRO(print_target_vehicle_name)

# Compare a vehicle name with the cache local to this repository.
# Creates a non-cache boolean variable, TARGET_VEHICLE_MATCHES and
# sets it to either "TRUE" or "FALSE" indicating whether the query
# string matches the cached vehicle name ${TARGET_VEHICLE} to be
# compiled for.
#
# Example usage:
# CHECK_TARGET_VEHICLE("NUI")
# IF (TARGET_VEHICLE_MATCHES)
#   ... compile, error out, set subdirectories, etc. 
# END (TARGET_VEHICLE_MATCHES)
MACRO(check_target_vehicle arg1)
  SET(TARGET_VEHICLE_MATCHES "FALSE")
  IF(${arg1} STREQUAL ${TARGET_VEHICLE})
    SET(TARGET_VEHICLE_MATCHES "TRUE")
  ENDIF(${arg1} STREQUAL ${TARGET_VEHICLE})
ENDMACRO(check_target_vehicle arg1)

# Compare the cache for this repository with the top-level cmake
# installation directory populated by dslmeta for consistency.  
MACRO(check_installed_target_vehicle)
  SET(INSTALLED_TARGET_VEHICLE_MATCHES "FALSE")

  MESSAGE("Installed vehicle target is ${INSTALLED_TARGET_VEHICLE}.  Target vehicle in this repository is ${TARGET_VEHICLE}.")
  
  IF(${TARGET_VEHICLE} STREQUAL ${INSTALLED_TARGET_VEHICLE})
    SET(INSTALLED_TARGET_VEHICLE_MATCHES "TRUE")
  ENDIF(${TARGET_VEHICLE} STREQUAL ${INSTALLED_TARGET_VEHICLE})
ENDMACRO(check_installed_target_vehicle)

# This macro is intended for inclusion in the top-level CMakeLists.txt
# file for any repositories that have an vehicle-specific conditional
# build process steps.  It requires users to clear their cache if it
# indicates previous builds were for a different vehicle.
MACRO(enable_target_vehicle_conditional_build)

  # Create vehicle conditional build cache variables if necessary.
  # This forces overwriting of the local cache variable
  # INSTALLED_TARGET_VEHICLE if it exists and creates it if not.
  FIND_PACKAGE(TARGET_VEHICLE REQUIRED)
  IF(TARGET_VEHICLE_FOUND)
    INCLUDE(${TARGET_VEHICLE_CONFIG})
  ELSE(TARGET_VEHICLE_FOUND)
    MESSAGE(FATAL_ERROR "Did you 'make install' dslmeta?  Doing so will generate and install the file 'target_vehicle.config' that cmake is looking for.")
  ENDIF(TARGET_VEHICLE_FOUND)

  # Check the locally cached target vehicle it against the installed
  # vehicle.  
  CHECK_INSTALLED_TARGET_VEHICLE(${TARGET_VEHICLE})

  # Require users to rebuild from scratch.
  IF(NOT INSTALLED_TARGET_VEHICLE_MATCHES)
    MESSAGE(FATAL_ERROR "The local CmakeCache.txt file indicates this repository was built previously for a different target vehicle.  Please remove all files in the build directory and build from scratch.")
  ENDIF(NOT INSTALLED_TARGET_VEHICLE_MATCHES)

ENDMACRO(enable_target_vehicle_conditional_build)

  # If the target vehicle matches 

# # * for normal users, just include the installed vehicle config - need to make this an
# #   easier macro.  Ignoring the usual if/else.
# FIND_PACKAGE(TARGET_VEHICLE REQUIRED)
# INCLUDE(${TARGET_VEHICLE_CONFIG})  # This forces the local cache entry to the installed vehicle, as set by dslmeta.  Now it's up to the developer to use the vehicle conditional buil macros (included by inclusion of dslmeta) to check before any conditional compilation or installation steps - generally this will be in CMakeList.txt subdirectories.  Unfortunately I don't know of any global way to prevent any/all installation if the target vehicle doesn't match.

# # * suppose I want to override the forced consistency with the installed target vehicle.  I can screw things up this way if I install, but this would allow me to develop and test locally for a different vehicle.  Wrap in an IF/ENDIF that allows a command-line option to avoid overwriting the target vehicle in the local cache?

