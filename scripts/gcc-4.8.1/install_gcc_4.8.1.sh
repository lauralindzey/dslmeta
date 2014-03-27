#!/bin/bash

# SS - script for building gcc-4.8.1 from source on Ubuntu 12.04

# http://gcc.gnu.org/wiki/InstallingGCC

# Download required packages via apt-get
sudo apt-get install libgmp-dev
sudo apt-get install libmpfr-dev
sudo apt-get install libmpc-dev
# Required to solve fatal error: bits/predefs.h: No such file or directory
# on 64-bit machine
sudo apt-get install gcc-multilib
# For make check
sudo apt-get install autogen


# Extract and build
tar xzf gcc-4.8.1.tar.gz
cd gcc-4.8.1
mkdir objdir
cd objdir
# Build only C and C++ compilers
$PWD/../../gcc-4.8.1/configure --prefix=/opt/gcc-4.8.1 --enable-languages=c,c++
# Build in parallel using 3 processes (ideal formula = n_cores * 1.5)
make -j3
make check
sudo make install

