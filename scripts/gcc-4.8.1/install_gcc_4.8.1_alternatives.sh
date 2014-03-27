# Update alternatives with highest priority (1)
sudo update-alternatives --install /usr/bin/gcc gcc /opt/gcc-4.8.1/bin/gcc 1
sudo update-alternatives --install /usr/bin/g++ g++ /opt/gcc-4.8.1/bin/g++ 1
sudo update-alternatives --config gcc
sudo update-alternatives --config g++

# Check versions
gcc --version
g++ --version

