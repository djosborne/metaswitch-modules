#!/bin/bash
wget https://github.com/apache/mesos/archive/0.28.0.tar.gz
tar -xvf 0.28.0.tar.gz

# GLOG
cd /root/glog
mv /root/mesos-0.28.0/3rdparty/libprocess/3rdparty/glog-0.3.3.tar.gz /root/glog
mv /root/mesos-0.28.0/3rdparty/libprocess/3rdparty/glog-0.3.3.patch /root/glog
tar -xvf glog-0.3.3.tar.gz
cd glog-0.3.3
git apply ../glog-0.3.3.patch
./configure

# BOOST
cd /root/boost
mv /root/mesos-0.28.0/3rdparty/libprocess/3rdparty/boost-1.53.0.tar.gz .
tar -xvf boost-1.53.0.tar.gz

# PROTOBUF
cd /root/protobuf
mv /root/mesos-0.28.0/3rdparty/libprocess/3rdparty/protobuf-2.5.0.tar.gz .
tar -xvf protobuf-2.5.0.tar.gz

./bootstrap
rm -rf build
mkdir build
cd build
export LD_LIBRARY_PATH=LD_LIBRARY_PATH:/usr/local/lib
../configure --with-mesos=/usr/local
make all

