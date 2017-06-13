#!/bin/sh

set -e

make distclean || true

# --with-openssl not good for Valgrind
# see https://postgr.es/m/20170329.142112.251668726.horiguchi.kyotaro%40lab.ntt.co.jp

# to build with python2 instead of python3
# export PYTHON=/usr/bin/python2

CFLAGS="-O0" ./configure --prefix=/home/eax/work/postgrespro/postgresql-install \
    --with-python --enable-tap-tests --enable-cassert --enable-debug \
    --enable-nls --with-perl --with-tcl --with-gssapi \
    --with-libxml --with-libxslt --with-ldap

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make -s -j4

echo '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'

make check
