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

# Specify the locations of child CMakeLists.txt files.
SUBDIRS( cmake etc )
