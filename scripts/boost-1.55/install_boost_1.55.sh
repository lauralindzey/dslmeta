#!/bin/bash

# SS - install boost 1.55

tar xzf boost_1_55_0.tar.gz
cd boost_1_55_0

#./bootstrap.sh --help
./bootstrap.sh --prefix=/opt/boost-1.55
sudo ./b2 install
