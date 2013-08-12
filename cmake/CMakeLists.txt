# dslmeta is intended to install things potentially useful across the
# suite of dsl software.  This script is atypical of what will be
# found in other $CMAKE_INSTALL_PREFIX/<project>/cmake directories.
# This script installs all .cmake files found here into
# $CMAKE_PREFIX_PATH/cmake/.  That is, the .cmake files here will not
# end up obviously associated with dslmeta by appearing in the more
# usual place, $CMAKE_INSTALL_PREFIX/lib/<project>/.
#
# The "config" form of cmake's find_package will always look for .cmake 
# files in $CMAKE_PREFIX_PATH/cmake, which should be set in a users .bashrc
# to $DSL_INSTALL_PREFIX (see the etc dir of this repo).

INSTALL(DIRECTORY ./
  DESTINATION cmake
  FILES_MATCHING PATTERN "*.cmake")
