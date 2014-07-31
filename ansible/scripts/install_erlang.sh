#!/bin/bash


# Erlang version to install
ERLv="R15B01"

mkdir -p work
pushd work

sudo apt-get update
sudo apt-get -y install build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev

wget http://erlang.org/download/otp_src_$ERLv.tar.gz
tar zxvf otp_src_$ERLv.tar.gz
pushd otp_src_$ERLv
./configure && make && sudo make install
popd
