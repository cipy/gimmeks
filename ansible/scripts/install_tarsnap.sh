#!/bin/bash


# tarsnap version to install
TSNAPv="1.0.35"

mkdir -p work
pushd work

sudo apt-get update
sudo apt-get -y install build-essential zlib1g zlib1g-dev libssl-dev libssl1.0.0 e2fslibs e2fslibs-dev

wget https://www.tarsnap.com/download/tarsnap-autoconf-$TSNAPv.tgz
tar zxvf tarsnap-autoconf-$TSNAPv.tgz
pushd tarsnap-autoconf-$TSNAPv
./configure && make all && sudo make install

popd
popd
