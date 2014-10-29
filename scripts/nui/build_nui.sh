#!/usr/bin/env bash
#
# 2014-10-28  MVJ  Prototyping...
#
# Builds and installs all repositories needed for NUI in dependency
# order.  Assumes all needed repositories have been checked out
# into a single directory, including dslmeta so that this script
# can be executed from this directory and use relative paths.
#
# This script handles vehicle-specific compilation only at the
# repository level - that is, it compiles and installs dslmeta for a
# specific vehicle, but does not descend into downstream repositories
# to build only components.  Instead downstream repositories with
# vehicle-specific build/install procedures are responsible for using
# the cmake macros defined in dslmeta to execute vehicle-specific
# builds.
#
# @@@ obviously need something that clones all the needed repos
# @@@ and places them into a tree of specific structure.
#
# @@@ either force deletion of /opt/dsl or allow soft-linking to 
# @@@ a new install directory as an option.

# Destroy any existing install.
if [ -d $DSL_INSTALL_PREFIX ]; then
    echo -n "Warning: Existing installation detected. About to remove all of $DSL_INSTALL_PREFIX.  Continue [Y/n]?"
    read yorn
    if [[ "$yorn" = "Y" || "$yorn" = "y" || -z "$yorn" ]]; then 
	sudo rm -rf $DSL_INSTALL_PREFIX
    else
	echo "Aborted."
	exit 0
    fi
fi

# Assume all repositories have been cloned into a common top-level 
# directory and that their names match the default.
cd ../../../
REPODIR=`pwd`

# Build and install dslmeta for NUI.  This populates the cache on a
# clean clone and checks for consistency with the target vehicle if
# the clone already exists.
cd $REPODIR/dslmeta/build/
cmake -DTARGET_VEHICLE:STRING=NUI ../
make
sudo make install

# Define repositories that need to be built for NUI 
# @@@ rename dslcore to dslprocess.
REPOS="dslcommon dslcore dsljoy dsldriver_proto"

for repo in $REPOS; do
    cd $REPODIR/$repo/build
    cmake ../
    make
    sudo make install
done;


