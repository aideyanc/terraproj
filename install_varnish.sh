#!/bin/bash
set -euo pipefail

apt-get update
apt-get install -y pkg-config automake tree autotools-dev libtool build-essential curl git libedit-dev autoconf-archive libjemalloc-dev libncurses-dev libpcre3-dev python3-sphinx python3-docutils

# Install varnish
git clone --single-branch --branch varnish-6.5.2 https://github.com/varnishcache/varnish-cache/
cd varnish-cache
./autogen.sh
./configure
make
make install
ldconfig
varnishd -V 2>&1 | grep "varnish-6.5.2"

# In docker land we need to expose port 80, not sure its relevant here
# Install varnish modules
git clone --single-branch --branch 6.5 https://github.com/varnish/varnish-modules.git
cd varnish-modules
./bootstrap
./configure
make
make install

# all need to be in the AMI, wihin the `/etc/varnish` directory so that we can boot up the command at the bottom of this
# backends.vcl
# whitelist.vcl 
# default.vcl 

# create /etc/varnish/default.vcl

# The AMI will need to launch with this command
varnishd -p vcl_path=/etc/varnish/ -a :80 -f /etc/varnish/default.vcl -p http_max_hdr=128
