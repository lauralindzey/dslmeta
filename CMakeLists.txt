# Meta-repository for DSL software.  Contains helper scripts and other 
# resources that are intended span the entire scope of DSL software.
#
#  Revision History
#  2013-03-15    mvj    Created.


PROJECT(dslmeta)

cmake_minimum_required(VERSION 2.8)

# cmake helper scripts are in subdir cmake.  Include these here.  
# Other projects will include them from their installed location.
INCLUDE( ${CMAKE_SOURCE_DIR}/cmake/dslmeta-config.cmake )

# dslmeta sets the target vehicle.  Confirm that any existing
# installation is consistent with the target vehicle specified
# during the current build and refuse to continue if not.  
# Handle the case of a clean reinstall by checking for existence.
IF(EXISTS "${CMAKE_INSTALL_PREFIX}/cmake/target_vehicle-config.cmake")
  INCLUDE("${CMAKE_INSTALL_PREFIX}/cmake/target_vehicle-config.cmake")
  CHECK_INSTALLED_TARGET_VEHICLE(${TARGET_VEHICLE})
  IF(NOT INSTALLED_TARGET_VEHICLE_MATCHES)
    MESSAGE(FATAL_ERROR "A previous installation exists on this machine for a different vehicle.  rm -rf /opt/dsl before reattempting installation.")
  ENDIF(NOT INSTALLED_TARGET_VEHICLE_MATCHES)
ENDIF(EXISTS "${CMAKE_INSTALL_PREFIX}/cmake/target_vehicle-config.cmake")

# Specify the locations of child CMakeLists.txt files.
SUBDIRS( cmake etc )
