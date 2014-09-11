#!/usr/bin/env bash
#
# Install the Rigid Body Dynamics Library: http://rbdl.bitbucket.org/index.html
#

# @@@ not implemented just wanted to note some things:
# eigen3 highly recommended (at least eigen2 required).  Use cmake to check for eigen3.
# get the latest stable release here: wget https://bitbucket.org/rbdl/rbdl/get/default.zip, by default dump this file in /opt, and unpack and compile it there.
# make user aware of location of .cmake helper scripts - and put one in the cmake dir here.  Or more better would be to make cmake aware of the helper scripts, probably by installing them in the /opt/dsl/cmake dir - that way we don't have to update them when eigen3 or rbdl updates those files.


